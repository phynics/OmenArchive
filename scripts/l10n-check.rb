#!/usr/bin/env ruby
# frozen_string_literal: true

# Reports nomenclature consistency across agent batches before merging.
# Usage: ruby scripts/l10n-check.rb [locale]

require "json"
require "yaml"

locale = ARGV[0] || "tr"
root = File.expand_path("..", __dir__)
ledger_path = File.join(root, "l10n", ".work", locale, "tasks.json")
abort "missing #{ledger_path}" unless File.file?(ledger_path)
ledger = JSON.parse(File.read(ledger_path))

tasks = (ledger["publications"] || {}).values.flat_map { |entry| entry["tasks"] }
english_to_turkish = Hash.new { |hash, key| hash[key] = Hash.new(0) }
missing = []
empty = []
unchanged = []
suspicious = []
counts = Hash.new(0)

STOPWORDS = /\b(the|and|of|with|your|you|from|when|while|this|that|into|onto|against|within)\b/i

# Same English word, different rules objects: a deliberate split, not drift.
INTENTIONAL = {
  "fly" => "Uçma (action) / Uçuş (spell)",
  "scout" => "İzci (background) / Gözcülük Yap (exploration action)",
  "warrior" => "Cenkçi (bard muse) / Muharip (background)",
  "mug" => "Gasp (action) / Kupa (item)"
}.freeze

source_names = {}
(ledger["publications"] || {}).each do |publication, _entry|
  %w[
    action spell item background feat ancestry class archetype domain
    versatile-heritage companion
  ].each do |family|
    dir = File.join(root, "src", publication, family)
    next unless File.directory?(dir)

    Dir.glob(File.join(dir, "**", "*.yml")).each do |file|
      relative = file.delete_prefix("#{root}/src/#{publication}/").sub(/\.yml\z/, "")
      record = YAML.load_file(file)
      next unless record.is_a?(Hash)

      source_names["omen://#{relative}?source=#{publication}"] = record["name"].to_s
    end
  end
end

tasks.each do |task|
  output = File.join(root, task["output"])
  input = JSON.parse(File.read(File.join(root, task["input"])))
  records = input["records"]

  unless File.exist?(output)
    missing << "#{task['taskId']} (#{records.length} records)"
    next
  end

  chunk = YAML.load_file(output)
  unless chunk.is_a?(Hash)
    empty << "#{task['taskId']}: not a mapping"
    next
  end

  records.each do |record|
    key = record["key"]
    english = source_names[key] || record["fields"]["name"].to_s
    turkish = chunk.dig(key, "name").to_s.strip

    if turkish.empty?
      empty << key
      next
    end

    counts[task["family"]] += 1
    english_to_turkish[english][turkish] += 1
    unchanged << "#{key}: #{english}" if english.casecmp?(turkish)
    suspicious << "#{key}: #{turkish}" if turkish.match?(STOPWORDS)
  end
end

intentional = english_to_turkish.select do |english, variants|
  variants.length > 1 && INTENTIONAL.key?(english.downcase)
end
conflicts = english_to_turkish.select do |english, variants|
  variants.length > 1 && !INTENTIONAL.key?(english.downcase)
end

puts "translated: #{counts.values.sum} records"
counts.sort.each { |family, count| puts format("  %-20s %5d", family, count) }

unless missing.empty?
  puts "\nmissing output (#{missing.length}):"
  missing.each { |entry| puts "  - #{entry}" }
end

unless empty.empty?
  puts "\nempty name (#{empty.length}):"
  empty.first(20).each { |entry| puts "  - #{entry}" }
end

unless conflicts.empty?
  puts "\ninconsistent names (#{conflicts.length}):"
  conflicts.first(30).each do |english, variants|
    puts "  - #{english}: #{variants.keys.join(' / ')}"
  end
end

unless intentional.empty?
  puts "\ncontext-distinct names (#{intentional.length}, allowed):"
  intentional.each do |english, variants|
    puts "  - #{english}: #{variants.keys.join(' / ')} (#{INTENTIONAL[english.downcase]})"
  end
end

unless unchanged.empty?
  puts "\nunchanged from English (#{unchanged.length}):"
  unchanged.first(20).each { |entry| puts "  - #{entry}" }
end

unless suspicious.empty?
  puts "\nsuspicious English words (#{suspicious.length}):"
  suspicious.first(20).each { |entry| puts "  - #{entry}" }
end

puts "\nprose coverage:"
(ledger["publications"] || {}).each do |publication, entry|
  total = entry["tasks"].flat_map do |task|
    JSON.parse(File.read(File.join(root, task["input"])))["records"].map { |record| record["key"] }
  end.uniq.length
  overrides = File.join(root, "l10n", locale, publication, "overrides")
  prose = Dir.glob(File.join(overrides, "*.yml")).sum do |file|
    (YAML.load_file(file) || {}).count { |_key, value| value.is_a?(Hash) && value["description"].to_s.strip != "" }
  end
  blocked = File.join(root, "l10n", ".work", locale, "blocked-#{publication}.json")
  held = File.file?(blocked) ? JSON.parse(File.read(blocked))["count"] : 0
  puts format("  %-34s %5d / %5d records, %d blocked on markup", publication, prose, total, held)
end

exit 1 unless missing.empty? || empty.empty?
