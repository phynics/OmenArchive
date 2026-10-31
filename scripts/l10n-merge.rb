#!/usr/bin/env ruby
# frozen_string_literal: true

# Validates localization agent output and merges it into the per-family
# overrides files. Existing entries are preserved; covered keys are replaced.
#
# Usage: ruby scripts/l10n-merge.rb <locale> <publication>

require "json"
require "yaml"
require "fileutils"

FIELDS = %w[
  name description trigger requirements frequency special
  criticalSuccess success failure criticalFailure prerequisites
].freeze

FAMILIES = %w[
  action spell item background feat ancestry class archetype domain
  versatile-heritage companion
].freeze

locale, publication = ARGV
abort "usage: l10n-merge.rb <locale> <publication>" unless locale && publication

root = File.expand_path("..", __dir__)
work = File.join(root, "l10n", ".work", locale)
ledger_path = File.join(work, "tasks.json")
abort "missing #{ledger_path}; run l10n-prepare.rb first" unless File.file?(ledger_path)
ledger = JSON.parse(File.read(ledger_path))
tasks = (ledger["publications"] || {}).values.flat_map { |entry| entry["tasks"] }

errors = []
warnings = []
merged = Hash.new { |hash, key| hash[key] = {} }

tasks.each do |task|
  next unless task["publication"] == publication

  output = File.join(root, task["output"])
  next unless File.exist?(output)

  input = JSON.parse(File.read(File.join(root, task["input"])))
  expected = input["records"].to_h { |record| [record["key"], record["fields"]] }
  token_sidecar = File.join(work, "tokens", "#{task['taskId']}.json")
  token_map = File.file?(token_sidecar) ? JSON.parse(File.read(token_sidecar)) : {}
  chunk = YAML.load_file(output)

  unless chunk.is_a?(Hash)
    errors << "#{task['taskId']}: output is not a mapping"
    next
  end

  chunk.each do |key, fields|
    unless expected.key?(key)
      errors << "#{task['taskId']}: unknown key #{key}"
      next
    end
    unless fields.is_a?(Hash)
      errors << "#{task['taskId']}: #{key} is not a mapping"
      next
    end

    unknown = fields.keys - FIELDS
    errors << "#{task['taskId']}: #{key} has unknown fields #{unknown.join(', ')}" unless unknown.empty?

    if fields["name"].to_s.strip.empty?
      errors << "#{task['taskId']}: #{key} has no name"
      next
    end

    # Restore the engine tokens the translator kept as opaque placeholders.
    mapping = token_map[key] || {}
    unless mapping.empty?
      restored = {}
      fields.each do |field, value|
        if value.is_a?(String)
          source_text = expected[key][field].to_s
          drift = mapping.keys.reject do |placeholder|
            value.scan(placeholder).size == source_text.scan(placeholder).size
          end
          if drift.empty?
            restored[field] = mapping.keys.reduce(value) { |acc, placeholder| acc.gsub(placeholder, mapping[placeholder]) }
          else
            warnings << "#{key}: #{field} changed token #{drift.join(', ')}; kept English"
            restored.delete(field)
          end
        else
          restored[field] = value
        end
      end
      fields = restored
    end

    if merged[task["family"]].key?(key)
      merged[task["family"]][key] = merged[task["family"]][key].merge(fields)
      next
    end

    source = expected[key]
    %w[description trigger requirements frequency special criticalSuccess success failure criticalFailure].each do |field|
      next unless source[field] && fields[field]
      if fields[field].to_s.strip == source[field].to_s.strip
        warnings << "#{key}: #{field} is unchanged from English"
      end
    end

    # The restored text must carry every engine token the source had.
    if (mapping = token_map[key]) && !mapping.empty?
      relative = key[/\Aomen:\/\/(.+?)\?/, 1]
      source_file = File.join(root, "src", publication, task["family"], "#{relative}.yml")
      if File.file?(source_file)
        original = YAML.load_file(source_file) || {}
        text = %w[description trigger requirements frequency special criticalSuccess success failure criticalFailure]
          .map { |field| original[field].to_s }.join(" ")
        mapping.each_value do |token|
          expected_count = text.scan(token).size
          actual_count = fields.values.map(&:to_s).join(" ").scan(token).size
          next if expected_count == actual_count

          warnings << "#{key}: token #{token} appears #{actual_count} time(s), source has #{expected_count}"
        end
      end
    end

    merged[task["family"]][key] = fields

    if fields["prerequisites"].is_a?(Array)
      fields["prerequisites"] = fields["prerequisites"].map do |entry|
        text = entry.is_a?(Hash) ? entry["text"] : entry
        { "text" => text.to_s } unless text.to_s.strip.empty?
      end.compact
      fields.delete("prerequisites") if fields["prerequisites"].empty?
    elsif fields.key?("prerequisites")
      errors << "#{task['taskId']}: #{key} prerequisites must be a list"
      fields.delete("prerequisites")
    end

    merged[task["family"]][key] = fields
  end
end

if errors.any?
  warn "validation failed with #{errors.length} error(s):"
  errors.first(40).each { |error| warn "  - #{error}" }
  warn "  ... #{errors.length - 40} more" if errors.length > 40
  exit 1
end

def scalar(value)
  text = value.to_s.gsub("\t", " ")
  return nil if text.strip.empty?

  if text.include?("\n")
    body = text.split("\n", -1).map { |line| line.empty? ? "" : "    #{line}" }
    ">\n#{body.join("\n")}"
  elsif text.match?(/\A[[:alnum:] ,.'’()\-–—\/&+%$]+\z/) && !text.start_with?(" ")
    text
  else
    text.to_json
  end
end

def emit(record)
  lines = []
  order = %w[
    name description trigger requirements frequency special prerequisites
    criticalSuccess success failure criticalFailure
  ]
  order.each do |field|
    value = record[field]
    next if value.nil?

    if field == "prerequisites"
      next if !value.is_a?(Array) || value.empty?

      lines << "  prerequisites:"
      value.each do |entry|
        lines << "  - text: #{entry['text'].to_s.gsub("\t", " ").to_json}"
      end
    else
      rendered = scalar(value)
      next unless rendered

      lines << "  #{field}: #{rendered}"
    end
  end
  lines.join("\n")
end

valid_keys = Hash.new { |hash, key| hash[key] = {} }
FAMILIES.each do |family|
  dir = File.join(root, "src", publication, family)
  next unless File.directory?(dir)

  Dir.glob(File.join(dir, "**", "*.yml")).each do |file|
    relative = file.delete_prefix("#{root}/src/#{publication}/").sub(/\.yml\z/, "")
    valid_keys[family]["omen://#{relative}?source=#{publication}"] = true
  end
end

counts = Hash.new(0)
FAMILIES.each do |family|
  path = File.join(root, "l10n", locale, publication, "overrides", "#{family}.yml")
  existing = File.exist?(path) ? (YAML.load_file(path) || {}) : {}
  stale = existing.keys - valid_keys[family].keys
  unless stale.empty?
    stale.each { |key| existing.delete(key) }
    warnings << "#{family}: dropped #{stale.length} stale override key(s)"
  end
  unless merged[family].empty? && stale.empty?
    entries = existing.merge(merged[family]) do |_key, current, incoming|
      current.merge(incoming)
    end
    FileUtils.mkdir_p(File.dirname(path))
    body = entries.keys.sort.map { |key| "#{key}:\n#{emit(entries[key])}" }.join("\n\n")
    File.write(path, "# #{locale} overrides: #{family}\n\n#{body}\n")
    existing = entries
  end
  counts[family] = existing.length
end

translated = counts.values.sum
total = FAMILIES.sum do |family|
  dir = File.join(root, "src", publication, family)
  File.directory?(dir) ? Dir.glob(File.join(dir, "**", "*.yml")).length : 0
end
status = if total.zero? then "seed"
         elsif translated >= total then "complete"
         elsif translated * 4 >= total then "in-progress"
         else "seed"
         end

manifest = File.join(root, "l10n", locale, publication, "manifest.yml")
if File.file?(manifest)
  text = File.read(manifest)
  text = text.sub(/^(\s*status:\s*).*$/) { "#{Regexp.last_match(1)}#{status}" }
  text = text.sub(/^(\s*translatedCount:\s*).*$/) { "#{Regexp.last_match(1)}#{translated}" }
  text = text.sub(/^(\s*totalCount:\s*).*$/) { "#{Regexp.last_match(1)}#{total}" }
  File.write(manifest, text)
end

puts "merged #{translated}/#{total} records (#{status})"
counts.sort.each { |family, count| puts format("%-20s %5d", family, count) }
unless warnings.empty?
  warn "#{warnings.length} warning(s) (first 15):"
  warnings.first(15).each { |warning| warn "  - #{warning}" }
end
