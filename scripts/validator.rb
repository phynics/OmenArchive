#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "optparse"
require "pathname"
require "yaml"

module OmenArchive
  class SchemaStore
    def initialize(schema_root)
      @schema_root = Pathname.new(schema_root).expand_path
      @cache = {}
    end

    def load_entry(schema_name)
      path = @schema_root.join(schema_name).cleanpath
      [load_file(path), path]
    end

    def resolve(ref, current_file)
      path_part, fragment = ref.split("#", 2)
      schema_path = if path_part.nil? || path_part.empty?
        current_file
      else
        current_file.dirname.join(path_part).cleanpath
      end

      schema = load_file(schema_path)
      [fragment ? resolve_pointer(schema, fragment) : schema, schema_path]
    end

    private

    def load_file(path)
      @cache[path.to_s] ||= JSON.parse(path.read)
    end

    def resolve_pointer(document, pointer)
      return document if pointer.nil? || pointer.empty?

      pointer.split("/").drop(1).reduce(document) do |memo, token|
        key = token.gsub("~1", "/").gsub("~0", "~")
        memo.fetch(key)
      end
    end
  end

  class JsonSchemaValidator
    UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i.freeze

    def initialize(schema_store)
      @schema_store = schema_store
    end

    def validate(data, schema, schema_file, data_path = "$")
      validate_schema(data, schema, schema_file, data_path)
    end

    private

    def validate_schema(value, schema, schema_file, data_path)
      if schema.key?("$ref")
        resolved_schema, resolved_file = @schema_store.resolve(schema.fetch("$ref"), schema_file)
        sibling_keywords = schema.reject { |key, _| key == "$ref" || key == "description" || key == "title" || key == "$schema" || key == "$id" || key == "default" }
        errors = validate_schema(value, resolved_schema, resolved_file, data_path)
        return errors if sibling_keywords.empty?

        return errors + validate_schema(value, sibling_keywords, schema_file, data_path)
      end

      errors = []
      errors.concat(validate_all_of(value, schema, schema_file, data_path))
      errors.concat(validate_one_of(value, schema, schema_file, data_path))
      errors.concat(validate_type(value, schema, data_path))
      errors.concat(validate_enum(value, schema, data_path))
      errors.concat(validate_const(value, schema, data_path))
      errors.concat(validate_format(value, schema, data_path))
      errors.concat(validate_numeric_bounds(value, schema, data_path))
      errors.concat(validate_object_keywords(value, schema, schema_file, data_path))
      errors.concat(validate_array_keywords(value, schema, schema_file, data_path))
      errors
    end

    def validate_all_of(value, schema, schema_file, data_path)
      return [] unless schema["allOf"]

      schema["allOf"].flat_map do |subschema|
        validate_schema(value, subschema, schema_file, data_path)
      end
    end

    def validate_one_of(value, schema, schema_file, data_path)
      return [] unless schema["oneOf"]

      matches = 0
      all_errors = []

      schema["oneOf"].each do |subschema|
        suberrors = validate_schema(value, subschema, schema_file, data_path)
        if suberrors.empty?
          matches += 1
        else
          all_errors.concat(suberrors)
        end
      end

      return [] if matches == 1

      message = if matches.zero?
        "#{data_path}: expected exactly one matching schema option"
      else
        "#{data_path}: matched multiple schema options"
      end

      [message, *all_errors].uniq
    end

    def validate_type(value, schema, data_path)
      expected = schema["type"]
      return [] unless expected

      types = Array(expected)
      return [] if types.any? { |type| type_match?(value, type) }

      ["#{data_path}: expected #{types.join(' or ')}, got #{json_type(value)}"]
    end

    def validate_enum(value, schema, data_path)
      return [] unless schema["enum"]
      return [] if schema["enum"].include?(value)

      ["#{data_path}: expected one of #{schema['enum'].join(', ')}, got #{value.inspect}"]
    end

    def validate_const(value, schema, data_path)
      return [] unless schema.key?("const")
      return [] if value == schema["const"]

      ["#{data_path}: expected #{schema['const'].inspect}, got #{value.inspect}"]
    end

    def validate_format(value, schema, data_path)
      return [] unless schema["format"] == "uuid" && value.is_a?(String)
      return [] if value.match?(UUID_PATTERN)

      ["#{data_path}: expected UUID, got #{value.inspect}"]
    end

    def validate_numeric_bounds(value, schema, data_path)
      return [] unless value.is_a?(Numeric)

      errors = []
      if schema.key?("minimum") && value < schema["minimum"]
        errors << "#{data_path}: expected >= #{schema['minimum']}, got #{value}"
      end
      if schema.key?("maximum") && value > schema["maximum"]
        errors << "#{data_path}: expected <= #{schema['maximum']}, got #{value}"
      end
      errors
    end

    def validate_object_keywords(value, schema, schema_file, data_path)
      return [] unless object_keywords?(schema)
      return ["#{data_path}: expected object, got #{json_type(value)}"] unless value.is_a?(Hash)

      errors = []

      Array(schema["required"]).each do |key|
        errors << "#{join_path(data_path, key)}: is required" unless value.key?(key)
      end

      if schema.key?("minProperties") && value.length < schema["minProperties"]
        errors << "#{data_path}: expected at least #{schema['minProperties']} properties, got #{value.length}"
      end
      if schema.key?("maxProperties") && value.length > schema["maxProperties"]
        errors << "#{data_path}: expected at most #{schema['maxProperties']} properties, got #{value.length}"
      end

      properties = schema["properties"] || {}
      matched_pattern_keys = {}
      pattern_properties = schema["patternProperties"] || {}
      properties.each do |key, subschema|
        next unless value.key?(key)

        errors.concat(validate_schema(value[key], subschema, schema_file, join_path(data_path, key)))
      end

      pattern_properties.each do |pattern, subschema|
        regex = Regexp.new(pattern)
        value.each do |key, child_value|
          next unless key.match?(regex)

          matched_pattern_keys[key] = true
          errors.concat(validate_schema(child_value, subschema, schema_file, join_path(data_path, key)))
        end
      end

      if schema["additionalProperties"] == false
        extra_keys = value.keys.reject { |key| properties.key?(key) || matched_pattern_keys[key] }
        extra_keys.each do |key|
          errors << "#{join_path(data_path, key)}: property is not allowed"
        end
      end

      errors
    end

    def validate_array_keywords(value, schema, schema_file, data_path)
      return [] unless array_keywords?(schema)
      return ["#{data_path}: expected array, got #{json_type(value)}"] unless value.is_a?(Array)

      errors = []
      if schema.key?("minItems") && value.length < schema["minItems"]
        errors << "#{data_path}: expected at least #{schema['minItems']} items, got #{value.length}"
      end

      if schema["items"]
        value.each_with_index do |item, index|
          errors.concat(validate_schema(item, schema["items"], schema_file, "#{data_path}[#{index}]"))
        end
      end

      errors
    end

    def object_keywords?(schema)
      schema.key?("properties") || schema.key?("required") || schema.key?("additionalProperties") ||
        schema.key?("minProperties") || schema.key?("maxProperties") || schema.key?("patternProperties")
    end

    def array_keywords?(schema)
      schema.key?("items") || schema.key?("minItems")
    end

    def type_match?(value, type)
      case type
      when "object" then value.is_a?(Hash)
      when "array" then value.is_a?(Array)
      when "string" then value.is_a?(String)
      when "integer" then value.is_a?(Integer)
      when "number" then value.is_a?(Numeric)
      when "boolean" then value == true || value == false
      when "null" then value.nil?
      else false
      end
    end

    def json_type(value)
      case value
      when Hash then "object"
      when Array then "array"
      when String then "string"
      when Integer then "integer"
      when Numeric then "number"
      when TrueClass, FalseClass then "boolean"
      when NilClass then "null"
      else value.class.name
      end
    end

    def join_path(prefix, key)
      "#{prefix}.#{key}"
    end
  end

  class ArchiveValidator
    SLUG_SAFE_CHARACTERS = /[^a-z0-9'()]+/.freeze

    def initialize(root:, schema_root:)
      @root = Pathname.new(root).expand_path
      @schema_root = Pathname.new(schema_root).expand_path
      @schema_store = SchemaStore.new(@schema_root)
      @json_schema_validator = JsonSchemaValidator.new(@schema_store)
    end

    def validate(paths = [])
      files = resolve_files(paths)
      errors = files.flat_map { |file| validate_file(file) }
      [files, errors]
    end

    private

    def resolve_files(paths)
      entries = if paths.empty?
        Dir.glob(@root.join("src/**/*.yml").to_s)
      else
        paths.flat_map { |path| expand_path_argument(path) }
      end

      entries.map { |entry| Pathname.new(entry).expand_path }.uniq.sort
    end

    def expand_path_argument(path)
      candidate = Pathname.new(path)
      candidate = @root.join(candidate) unless candidate.absolute?
      if candidate.directory?
        Dir.glob(candidate.join("**/*.yml").to_s)
      else
        [candidate.to_s]
      end
    end

    def validate_file(file_path)
      errors = []
      relative_path = relative_to_root(file_path)

      contents = read_utf8(file_path, errors, relative_path)
      return errors unless contents

      resource = parse_yaml(contents, errors, relative_path)
      return errors unless resource
      return errors << "#{relative_path}: expected top-level object" unless resource.is_a?(Hash)

      path_info = classify_path(relative_path, errors)
      return errors unless path_info

      validate_source_book(resource, errors, relative_path)
      validate_filename(resource, path_info, errors, relative_path)
      validate_ancestry(resource, path_info, errors, relative_path)

      schema, schema_file = @schema_store.load_entry(path_info.fetch(:schema))
      schema_errors = @json_schema_validator.validate(resource, schema, schema_file)
      schema_errors.each do |message|
        errors << "#{relative_path}: #{message}"
      end

      errors
    end

    def read_utf8(file_path, errors, relative_path)
      bytes = File.binread(file_path)
      if utf16_bom?(bytes) || bytes.include?("\x00")
        errors << "#{relative_path}: file is not UTF-8 text (looks like UTF-16 or binary)"
        return
      end

      text = bytes.dup.force_encoding(Encoding::UTF_8)
      unless text.valid_encoding?
        errors << "#{relative_path}: file is not valid UTF-8 text"
        return
      end

      text
    end

    def parse_yaml(contents, errors, relative_path)
      YAML.safe_load(contents, permitted_classes: [], permitted_symbols: [], aliases: false)
    rescue Psych::Exception => e
      errors << "#{relative_path}: YAML parse failed: #{e.message}"
      nil
    end

    def classify_path(relative_path, errors)
      parts = relative_path.each_filename.to_a
      unless parts.first == "src" && parts.length >= 4
        errors << "#{relative_path}: path must live under src/{publication}/{category}/..."
        return
      end

      publication = parts[1]
      category = parts[2]
      filename = parts.last
      basename = File.basename(filename, ".yml")

      info = { publication: publication, category: category, basename: basename, parts: parts }

      case category
      when "action"
        return info.merge(schema: "character-action.schema.json") if parts.length == 4
      when "background"
        return info.merge(schema: "character-background.schema.json") if parts.length == 4
      when "feat"
        return info.merge(schema: "character-feat.schema.json") if parts.length == 4
      when "ancestry"
        ancestry = parts[3]
        if parts.length == 5 && basename == ancestry
          return info.merge(schema: "character-ancestry.schema.json", ancestry_directory: ancestry)
        end
        if parts.length == 6 && parts[4] == "features"
          return info.merge(schema: "character-feature.schema.json", ancestry_directory: ancestry)
        end
      when "heritage"
        ancestry = parts[3]
        return info.merge(schema: "character-heritage.schema.json", ancestry_directory: ancestry) if parts.length == 5
      when "class"
        class_name = parts[3]
        if parts.length == 5 && basename == class_name
          return info.merge(schema: "character-class.schema.json", class_directory: class_name)
        end
        return info.merge(schema: "character-feature.schema.json", class_directory: class_name) if parts.length == 6
      when "other-items"
        return info.merge(schema: "other-item.schema.json") if parts.length >= 5
      end

      errors << "#{relative_path}: cannot determine schema from directory layout"
      nil
    end

    def validate_source_book(resource, errors, relative_path)
      book = resource.dig("source", "book")
      return if book.is_a?(String) && !book.strip.empty?

      errors << "#{relative_path}: source.book is required"
    end

    def validate_filename(resource, path_info, errors, relative_path)
      name = resource["name"]
      return unless name.is_a?(String)

      expected_slugs = expected_slugs_for(name, path_info)
      actual_slug = path_info.fetch(:basename)
      return if expected_slugs.include?(actual_slug)

      errors << "#{relative_path}: filename slug #{actual_slug.inspect} does not match name slug #{expected_slugs.first.inspect}"
    end

    def validate_ancestry(resource, path_info, errors, relative_path)
      return unless path_info[:category] == "heritage"

      actual = resource["ancestry"]
      expected = path_info[:ancestry_directory]
      return if actual == expected

      errors << "#{relative_path}: heritage ancestry #{actual.inspect} does not match directory #{expected.inspect}"
    end

    def utf16_bom?(bytes)
      bytes.start_with?("\xFF\xFE".b) || bytes.start_with?("\xFE\xFF".b)
    end

    def relative_to_root(file_path)
      Pathname.new(file_path).expand_path.relative_path_from(@root)
    end

    def slugify(name)
      name.strip.downcase.gsub(SLUG_SAFE_CHARACTERS, "-").gsub(/^-+|-+$/, "")
    end

    def expected_slugs_for(name, path_info)
      primary = slugify(name)
      expected = [primary, simplify_slug(primary)]

      case path_info[:category]
      when "class"
        expected.concat(class_slug_variants(expected, path_info))
      when "other-items"
        expected.concat(other_item_slug_variants(primary, path_info))
      end

      expected.uniq.reject(&:empty?)
    end

    def class_slug_variants(expected_slugs, path_info)
      variants = []
      class_section = path_info[:parts][4]

      if class_section == "features" && path_info[:basename] =~ /\A\d+-/
        level_prefix = path_info[:basename][/^\d+-/]
        expected_slugs.each do |slug|
          variants << "#{level_prefix}#{slug}"
          class_name = path_info[:class_directory]
          variants << "#{level_prefix}#{slug}-(#{class_name})"
        end
      end

      case class_section
      when "schools"
        expected_slugs.each do |slug|
          variants << slug.delete_prefix("school-of-")
          variants << slug.delete_prefix("school-of-the-")
        end
      when "basic-lessons", "greater-lessons", "major-lessons"
        expected_slugs.each do |slug|
          variants << slug.delete_prefix("lesson-of-the-")
          variants << slug.delete_prefix("lesson-of-")
        end
      end

      variants
    end

    def other_item_slug_variants(primary, path_info)
      group = path_info[:parts][3]
      singular_group = group.end_with?("s") ? group[0...-1] : group
      suffix = "-#{singular_group}"
      return [] unless primary.end_with?(suffix)

      [primary.delete_suffix(suffix), simplify_slug(primary.delete_suffix(suffix))]
    end

    def simplify_slug(slug)
      slug.delete("'").gsub(/[()]/, "")
    end
  end

  class CLI
    def self.run(argv)
      options = parse_options(argv)
      validator = ArchiveValidator.new(root: options.fetch(:root), schema_root: options.fetch(:schema_root))
      files, errors = validator.validate(argv)

      if errors.empty?
        puts "Validated #{files.length} file(s)"
        return 0
      end

      errors.each { |error| warn error }
      warn "Validation failed for #{errors.length} issue(s) across #{files.length} file(s)"
      1
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
      warn e.message
      2
    rescue Errno::ENOENT => e
      warn e.message
      2
    end

    def self.parse_options(argv)
      repo_root = Pathname.new(__dir__).join("..").expand_path
      options = {
        root: repo_root,
        schema_root: repo_root.join("schemas")
      }

      OptionParser.new do |parser|
        parser.on("--root PATH", "Repository root containing src/") do |value|
          options[:root] = Pathname.new(value).expand_path
        end
        parser.on("--schema-root PATH", "Schema root directory") do |value|
          options[:schema_root] = Pathname.new(value).expand_path
        end
      end.parse!(argv)

      options
    end
  end
end

exit OmenArchive::CLI.run(ARGV) if $PROGRAM_NAME == __FILE__
