#!/usr/bin/env ruby
# frozen_string_literal: true

# Rewrite authored effect recipes from the pre-registry representation to the
# OmenMechanics wire representation. The operation is intentionally
# deterministic and fails before writing when an unrecognized authored shape is
# encountered.

require "pathname"
require "yaml"

module MechanicsRewrite
  MODULE = "org.openomen.pf2e.core"
  VALUE_SLUGS = {
    "uuid" => "uuid",
    "string" => "string",
    "int" => "int",
    "skill" => "skill",
    "proficiencyRank" => "proficiency-rank",
    "featId" => "feat-id",
    "actionId" => "action-id",
    "bool" => "bool",
    "savingThrow" => "saving-throw",
    "weaponDesignation" => "weapon-designation",
    "weaponGroup" => "weapon-group"
  }.freeze
  PARAMETER_TYPES_BY_SLUG = VALUE_SLUGS.each_with_object({}) { |(name, slug), result| result[slug] = name }.freeze

  EFFECT_SLUGS = {
    "addSkillIncrease" => "add-skill-increase",
    "addFeat" => "add-feat",
    "addSpeedModifier" => "add-speed-modifier",
    "addAction" => "add-action",
    "addBaseSpeed" => "add-base-speed",
    "addAssurance" => "add-assurance",
    "addTerrainStalker" => "add-terrain-stalker",
    "addResistance" => "add-resistance",
    "addCraftingAbility" => "add-crafting-ability",
    "addSavingThrow" => "add-saving-throw",
    "addWeaponProficiency" => "add-weapon-proficiency",
    "addWeaponCriticalSpecialization" => "add-weapon-critical-specialization"
  }.freeze

  PROFICIENCIES = {
    "untrained" => 0,
    "trained" => 2,
    "expert" => 4,
    "master" => 6,
    "legendary" => 8
  }.freeze

  module_function

  def value_type_id(parameter_type)
    slug = VALUE_SLUGS.fetch(parameter_type) do
      raise "unrecognized parameterType #{parameter_type.inspect}"
    end
    "#{MODULE}/value/#{slug}"
  end

  def effect_kind_id(kind)
    slug = EFFECT_SLUGS.fetch(kind) do
      raise "unrecognized effect kind #{kind.inspect}"
    end
    "#{MODULE}/effect/#{slug}"
  end

  def registered_value(parameter_type, literal)
    if literal.is_a?(Hash) && literal.key?("typeID") && literal.key?("payload")
      expected_type = value_type_id(parameter_type)
      raise "registered value #{literal["typeID"].inspect} does not match #{expected_type.inspect}" unless literal["typeID"] == expected_type
      return literal.merge("payload" => codable_payload(parameter_type, literal.fetch("payload")))
    end
    raise "literal must be a single-key object" unless literal.is_a?(Hash) && literal.length == 1

    key, value = literal.first
    expected = VALUE_SLUGS.fetch(parameter_type) do
      raise "unrecognized parameterType #{parameter_type.inspect}"
    end
    actual = VALUE_SLUGS.fetch(key) do
      raise "literal key #{key.inspect} does not identify a registered value"
    end
    raise "literal #{key.inspect} does not match #{parameter_type.inspect}" unless actual == expected

    payload = case parameter_type
    when "uuid", "featId", "actionId"
      value.to_s.downcase
    when "proficiencyRank"
      PROFICIENCIES.fetch(value.to_s) { raise "unknown proficiency rank #{value.inspect}" }
    else
      codable_payload(parameter_type, value)
    end

    {
      "typeID" => value_type_id(parameter_type),
      "revision" => 1,
      "payload" => payload
    }
  end

  # Domain values use the stable codecs exported by OmenCoreMechanics. Keep
  # this representation explicit so authored data is independent of Swift's
  # synthesized enum encoding.
  def codable_payload(parameter_type, value)
    case parameter_type
    when "skill"
      if value.is_a?(Hash)
        return value if value.key?("kind")
        return { "kind" => value.keys.first } if value.length == 1
      end
      { "kind" => value.to_s }
    when "weaponGroup"
      if value.is_a?(String)
        # Normalize an intermediate synthesized-payload string left by an
        # earlier idempotent rewrite (for example, {"any"=>{}}).
        return Regexp.last_match(1) if value.match(/\A\{"([^\"]+)"=>\{\}\}\z/)
        return value
      end
      return value.fetch("name") if value.is_a?(Hash) && value.key?("name")
      return value.keys.first if value.is_a?(Hash) && value.length == 1
      value.to_s
    when "weaponDesignation"
      if value.is_a?(Hash)
        return value if value.key?("kind")
        if value.key?("specific")
          return { "kind" => "specific", "name" => value.fetch("specific").fetch("_0") }
        end
        if value.key?("filter")
          filter = value.fetch("filter").fetch("_0")
          return {
            "kind" => "filter",
            "weaponKind" => filter.fetch("kind").keys.first,
            "weaponGroup" => filter.fetch("group").keys.first
          }
        end
      end
      text = value.to_s
      if text.start_with?("kind:")
        kind, group = text.delete_prefix("kind:").split(";group:", 2)
        raise "invalid weapon designation #{value.inspect}" if group.nil? || kind.empty? || group.empty?
        {
          "kind" => "filter",
          "weaponKind" => kind,
          "weaponGroup" => group
        }
      elsif text.start_with?("specific:")
        specific = text.delete_prefix("specific:")
        raise "invalid weapon designation #{value.inspect}" if specific.empty?
        { "kind" => "specific", "name" => specific }
      else
        raise "invalid weapon designation #{value.inspect}"
      end
    else
      value
    end
  end

  def selection(parameter_type, source)
    descriptor = source.fetch("selection")
    options = descriptor.fetch("options")
    values = if options.is_a?(Hash) && options["kind"] == "explicit"
      options.fetch("values")
    else
      options.map { |literal| registered_value(parameter_type, literal) }
    end
    {
      "id" => descriptor.fetch("id").to_s.downcase,
      "lookupName" => descriptor.fetch("lookupName"),
      "valueTypeID" => value_type_id(parameter_type),
      "options" => {
        "kind" => "explicit",
        "values" => values.map { |literal| registered_value(parameter_type, literal) }
      }
    }
  end

  def source(parameter_type, old_source)
    if old_source["kind"] == "literal"
      return {
        "kind" => "literal",
        "value" => registered_value(parameter_type, old_source.fetch("value"))
      }
    elsif old_source["kind"] == "selection"
      return { "kind" => "selection", "selection" => selection(parameter_type, old_source) }
    elsif old_source["kind"] == "lookupByName"
      return old_source
    elsif old_source["kind"] == "lookupByID"
      return old_source
    end

    if old_source.key?("literal")
      {
        "kind" => "literal",
        "value" => registered_value(parameter_type, old_source.fetch("literal"))
      }
    elsif old_source.key?("selection")
      { "kind" => "selection", "selection" => selection(parameter_type, old_source) }
    elsif old_source.key?("lookupByName")
      { "kind" => "lookupByName", "name" => old_source.fetch("lookupByName") }
    elsif old_source.key?("lookupByID")
      { "kind" => "lookupByID", "id" => old_source.fetch("lookupByID").to_s.downcase }
    else
      raise "unrecognized value source #{old_source.inspect}"
    end
  end

  def recipe(old_recipe)
    expected = old_recipe.fetch("expectedValue")
    parameter_type = expected["parameterType"]
    if parameter_type.nil?
      type_id = expected.fetch("valueTypeID")
      parameter_type = PARAMETER_TYPES_BY_SLUG.fetch(type_id.split("/").last) do
        raise "unrecognized value type ID #{type_id.inspect}"
      end
    end
    old_source = expected["valueFromSource"] || expected.fetch("source")
    {
      "inputName" => old_recipe.fetch("inputName"),
      "expectedValue" => {
        "valueTypeID" => value_type_id(parameter_type),
        "source" => source(parameter_type, old_source)
      }
    }
  end

  def rule(old_rule)
    template = old_rule["effectTemplate"]
    template ||= {
      "kind" => old_rule.fetch("effectReference").fetch("kindID").split("/").last,
      "inputRecipes" => old_rule.fetch("inputRecipes")
    }
    kind_id = if old_rule["effectReference"]
      old_rule.fetch("effectReference")
    else
      { "kindID" => effect_kind_id(template.fetch("kind")), "revision" => 1 }
    end
    rewritten = {
      "id" => old_rule.fetch("id").to_s.downcase,
      "effectReference" => kind_id,
      "inputRecipes" => Array(template["inputRecipes"]).map { |recipe| recipe(recipe) },
      "startLevel" => old_rule.fetch("startLevel")
    }
    rewritten["prerequisites"] = old_rule["prerequisites"] if old_rule.key?("prerequisites")
    rewritten
  end

  def rewrite_file(path)
    document = YAML.safe_load(path.read, aliases: true)
    return false unless document.is_a?(Hash) && document.key?("rules")

    document["rules"] = document.fetch("rules").map { |old_rule| rule(old_rule) }
    path.write(YAML.dump(document))
    true
  end

  def run(root)
    paths = Dir[root.join("**/*.yml")].map { |path| Pathname.new(path) }
      .reject { |path| path.basename.to_s == "publication.yml" }
    rule_paths = paths.select do |path|
      document = YAML.safe_load(path.read, aliases: true)
      document.is_a?(Hash) && document.key?("rules")
    end
    rule_paths.each { |path| rewrite_file(path) }
    puts "rewrote #{rule_paths.length} rule-bearing YAML files"
  end
end

root = Pathname.new(ARGV.fetch(0, File.expand_path("../src/paizo-pathfinder-player-core", __dir__))).expand_path
MechanicsRewrite.run(root)
