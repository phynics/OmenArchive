#!/usr/bin/env ruby
# frozen_string_literal: true

# Splits a publication's translatable text into deterministic work units for
# localization agents. Writes one JSON input per task and a tasks.json ledger.
#
# Usage:
#   ruby scripts/l10n-prepare.rb <locale> <publication> [names|full] [char-budget]
#
# names  translates display names only (first nomenclature pass)
# full   translates names and all rules prose

require "json"
require "yaml"
require "fileutils"

TEXT_FIELDS = %w[
  description trigger requirements frequency special
  criticalSuccess success failure criticalFailure
].freeze

ALL_FIELDS = (["name"] + TEXT_FIELDS).freeze

FAMILIES = %w[
  action spell item background feat ancestry class archetype domain
  versatile-heritage companion
].freeze

locale, publication, mode, budget, only_family = ARGV
abort "usage: l10n-prepare.rb <locale> <publication> [names|full] [char-budget] [family]" unless locale && publication
mode = (mode || "names").downcase
abort "mode must be names or full" unless %w[names full].include?(mode)
budget = (budget || (mode == "names" ? 12_000 : 48_000)).to_i
record_cap = mode == "names" ? 260 : 220
families = only_family ? FAMILIES.select { |family| family == only_family } : FAMILIES
abort "unknown family #{only_family}" if only_family && families.empty?

def prose_translated?(entry, record)
  return false unless entry.is_a?(Hash)
  fields = record_fields(record, "full").reject { |field, _| field == "name" }
  fields.all? do |field, value|
    localized = entry[field]
    if value.is_a?(Array)
      localized.is_a?(Array) && !localized.empty?
    else
      localized.to_s.strip != ""
    end
  end
end

root = File.expand_path("..", __dir__)
src = File.join(root, "src", publication)
abort "missing #{src}" unless File.directory?(src)

work = File.join(root, "l10n", ".work", locale)
input_dir = File.join(work, "input")
token_dir = File.join(work, "tokens")
FileUtils.mkdir_p(input_dir)
ledger_path = File.join(work, "tasks.json")
previous = File.file?(ledger_path) ? JSON.parse(File.read(ledger_path)) : {}
publications = previous["publications"] || {}
previous_tasks = publications.dig(publication, "tasks") || []

def task_files_valid?(root, task)
  input_path = File.join(root, task["input"])
  return false unless File.file?(input_path)

  input = JSON.parse(File.read(input_path))
  expected = input.fetch("records").map { |record| record.fetch("key") }.sort
  return false unless input["recordCount"] == expected.length

  sidecar = File.join(root, "l10n", ".work", task["locale"], "tokens", "#{task['taskId']}.json")
  if File.read(input_path).include?("%%T")
    return false unless File.file?(sidecar)
  end

  output_path = File.join(root, task["output"])
  return true unless File.file?(output_path)

  output = YAML.load_file(output_path)
  output.is_a?(Hash) && output.keys.sort == expected
rescue StandardError
  false
end

reserved_keys = previous_tasks.select do |task|
  task["mode"] == mode && families.include?(task["family"]) && task_files_valid?(root, task)
end.flat_map do |task|
  JSON.parse(File.read(File.join(root, task["input"])))["records"].map { |record| record["key"] }
end.each_with_object({}) { |key, keys| keys[key] = true }

existing_overrides = File.join(root, "l10n", locale, publication, "overrides")
already = {}
Dir.glob(File.join(existing_overrides, "*.yml")).each do |file|
  (YAML.load_file(file) || {}).each { |key, entry| already[key] = entry }
rescue StandardError
  next
end

short = publication.sub("paizo-pathfinder-", "").gsub(/-core$/, "").gsub("-", "")
short = "pc2" if publication.end_with?("player-core-2")
short = "pc" if publication.end_with?("player-core")

MARKUP = /@|type:(?:cone|line|burst|emanation)|\[[^\]\n]+\]|,?[a-z]+:[a-z]+/

# Engine and converter tokens that must survive translation byte for byte.
TOKEN_SCRUBBERS = [
  /\[\[[^\]\n]{0,200}\]\]/,                   # [[/br 2]]
  /\[[^\]\n]{0,200}\]/,                       # [persistent,fire]
  /\b[a-z][a-z0-9-]*(?:\|[a-z0-9:_-]+)+\b/i,  # fortitude|against:rogue, will|basic
  /\|[a-z0-9:_-]+/i,                          # |options:area-damage
  /@actor\.[a-z]+/i,                          # @actor.level
  /\btype:[a-z]+/i,                           # type:cone
  /,[a-z]+:[a-z]+/i                           # ,inflicts:frightened
].freeze

# A parenthesised group is a formula only when it calls a rule function or
# reads an actor attribute; ordinary prose parentheses stay translatable.
PAREN_FORMULA = /\((?:[^()]|\([^()]*\))*\)/
FORMULA_CALL = /(?:ceil|floor|max|min|sum)\s*\(|\@/i

def extract_tokens(text)
  tokens = []
  protect_tokens(text, tokens)
  tokens
end

def clean_text(text)
  text.gsub(/\s{2,}/, " ").strip
end

def raw_prose(record)
  values = TEXT_FIELDS.map { |field| record[field] }
  values += record["prerequisites"].map { |entry| entry.is_a?(Hash) ? entry["text"] : entry } if record["prerequisites"].is_a?(Array)
  values.compact.map(&:to_s)
end

# Replaces engine and converter tokens with opaque placeholders so translators
# cannot translate, drop, or reorder them. The map is written to a sidecar file
# the agents never read; the merge step restores the original tokens.
def protect_tokens(text, tokens)
  scrubbed = text.dup

  scrubbed = scrubbed.gsub(PAREN_FORMULA) do |match|
    next match unless match.match?(FORMULA_CALL)

    tokens << match
    "%%T#{tokens.length}%%"
  end

  TOKEN_SCRUBBERS.each do |pattern|
    scrubbed = scrubbed.gsub(pattern) do |match|
      tokens << match
      "%%T#{tokens.length}%%"
    end
  end

  scrubbed
end

def record_fields(record, mode, tokens = nil)
  fields = {}
  fields["name"] = record["name"].to_s unless record["name"].to_s.empty?
  return fields if mode == "names"

  TEXT_FIELDS.each do |field|
    value = record[field]
    next if value.nil? || value.to_s.empty?

    text = clean_text(value.to_s)
    text = protect_tokens(text, tokens) if tokens
    fields[field] = text
  end
  prerequisites = record["prerequisites"]
  if prerequisites.is_a?(Array) && !prerequisites.empty?
    texts = prerequisites.map do |entry|
      entry.is_a?(Hash) ? entry["text"] : entry
    end.compact.map { |text| clean_text(text.to_s) }.reject(&:empty?)
    if tokens
      texts = texts.map { |text| protect_tokens(text, tokens) }
    end
    fields["prerequisites"] = texts.map { |text| { "text" => text } } unless texts.empty?
  end
  fields
end

def char_count(fields)
  fields.sum do |key, value|
    if key == "prerequisites"
      value.sum { |entry| entry["text"].length }
    else
      value.length
    end
  end
end

def context_for(record)
  text = record["description"].to_s.strip
  text = record["trigger"].to_s.strip if text.empty?
  text.length > 120 ? "#{text[0, 120]}…" : text
end

tasks = []
counts = {}
blocked = []

families.each do |family|
  dir = File.join(src, family)
  next unless File.directory?(dir)

  records = []
  Dir.glob(File.join(dir, "**", "*.yml")).sort.each do |file|
    relative = file.delete_prefix("#{src}/").sub(/\.yml\z/, "")
    key = "omen://#{relative}?source=#{publication}"
    record = YAML.load_file(file)
    next if reserved_keys[key]
    next if already[key] && (mode == "names" || prose_translated?(already[key], record))
    next unless record.is_a?(Hash)

    if mode == "full"
      untranslatable = raw_prose(record).any? do |text|
        scrubbed, = protect_tokens(clean_text(text), [])
        scrubbed.strip.empty? || !scrubbed.match?(/[a-z]{3,}/i)
      end
      if untranslatable
        blocked << { "key" => key, "sample" => raw_prose(record).first.to_s[0, 160] }
        next
      end
    end

    tokens = []
    fields = record_fields(record, mode, mode == "full" ? tokens : nil)
    if mode == "full" && already[key].is_a?(Hash) && !already[key]["name"].to_s.empty?
      fields["name"] = already[key]["name"]
    end
    next if fields.empty? || fields["name"].nil?

    entry = { "key" => key, "fields" => fields }
    entry["context"] = context_for(record) if mode == "names"
    unless tokens.empty?
      entry["tokenMap"] = tokens.each_with_object({}) { |token, map| map["%%T#{map.length + 1}%%"] = token }
    end
    records << entry
  end
  next if records.empty?

  counts[family] = records.length

  chunk = []
  chars = 0
  flush = lambda do
    unless chunk.empty?
      previous_indices = previous_tasks.map do |task|
        next unless task["mode"] == mode && task["family"] == family

        (task["taskId"].to_s[/\d+\z/] || "0").to_i
      end.compact
      index = [previous_indices.max || 0, tasks.count { |task| task["family"] == family }].max + 1
      prefix = mode == "full" ? "full-" : ""
      task_id = format("tr-%s-%s-%s%02d", short, family.tr("-", ""), prefix, index)
      while File.exist?(File.join(work, "out", "#{task_id}.yml"))
        index += 1
        task_id = format("tr-%s-%s-%s%02d", short, family.tr("-", ""), prefix, index)
      end
      input = File.join(input_dir, "#{task_id}.json")
      token_map = chunk.each_with_object({}) do |record, map|
        map[record["key"]] = record.delete("tokenMap") if record.key?("tokenMap")
      end
      File.write(input, JSON.pretty_generate(
        "taskId" => task_id,
        "locale" => locale,
        "publication" => publication,
        "family" => family,
        "mode" => mode,
        "recordCount" => chunk.length,
        "records" => chunk
      ))
      unless token_map.empty?
        sidecar = File.join(token_dir, "#{task_id}.json")
        FileUtils.mkdir_p(token_dir)
        File.write(sidecar, JSON.pretty_generate(token_map))
      end
      tasks << {
        "taskId" => task_id,
        "locale" => locale,
        "publication" => publication,
        "family" => family,
        "mode" => mode,
        "input" => input.delete_prefix("#{root}/"),
        "output" => "l10n/.work/#{locale}/out/#{task_id}.yml",
        "recordCount" => chunk.length,
        "charCount" => chars
      }
      chunk = []
      chars = 0
    end
  end

  records.each do |record|
    size = char_count(record["fields"])
    if !chunk.empty? && (chars + size > budget || chunk.length >= record_cap)
      flush.call
    end
    chunk << record
    chars += size
  end
  flush.call
end

kept = previous_tasks.select do |task|
  ! (task["mode"] == mode && families.include?(task["family"])) || task_files_valid?(root, task)
end
publications[publication] = {
  "families" => counts,
  "tasks" => kept + tasks
}
File.write(ledger_path, JSON.pretty_generate(
  "locale" => locale,
  "mode" => mode,
  "charBudget" => budget,
  "publications" => publications
))

puts "wrote #{ledger_path} (#{mode})"
path = File.join(work, "blocked-#{publication}.json")
File.write(path, JSON.pretty_generate("publication" => publication, "count" => blocked.length, "records" => blocked))
puts format("%-20s %3d records blocked on markup (%s)", "blocked", blocked.length, path)
tasks.group_by { |task| task["family"] }.each do |family, list|
  chars = list.sum { |task| task["charCount"] }
  records = list.sum { |task| task["recordCount"] }
  puts format("%-20s %3d tasks %5d records %8d chars", family, list.length, records, chars)
end
