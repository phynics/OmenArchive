#!/usr/bin/env ruby
# Fold per-batch decision proposals into l10n/<locale>/DECISIONS.md.
#
# Usage: ruby scripts/l10n-decisions-merge.rb [locale]
#
# Reads every l10n/<locale>/.work/*/decisions/*.md table row, skips terms already
# settled in the ledger, assigns stable IDs in a generated section, and keeps an
# existing row's ID and status on later runs.

require "yaml"

locale = ARGV[0] || "tr"
root = File.expand_path("../l10n/#{locale}", __dir__)
ledger_path = File.join(root, "DECISIONS.md")
abort "missing #{ledger_path}" unless File.exist?(ledger_path)

START = "<!-- batch-proposals:start -->".freeze
STOP = "<!-- batch-proposals:end -->".freeze

def norm(term)
  term.to_s.downcase.gsub(/\s+/, " ").strip
end

def parse_table(path)
  rows = []
  File.readlines(path, encoding: "UTF-8").each do |line|
    next unless line.start_with?("|")
    cells = line.split("|").map(&:strip)
    cells.shift if cells.first == ""
    cells.pop if cells.last == ""
    next unless cells.size >= 4
    next if cells[0].downcase == "term" || cells[0].match?(/\A-+\z/)
    term, proposal, alternatives, reason = cells
    rows << {
      "term" => term,
      "proposal" => proposal,
      "alternatives" => alternatives == "—" ? "" : alternatives,
      "reason" => reason
    }
  end
  rows
end

ledger = File.read(ledger_path, encoding: "UTF-8")
head = ledger.split(START, 2).first.to_s

settled = {}
head.each_line do |line|
  next unless line.start_with?("| D")
  cells = line.split("|").map(&:strip)
  cells.shift if cells.first == ""
  scope = cells[1].to_s
  base = norm(scope.split("(").first)
  settled[base] = true unless base.empty?
end

existing = {}
if ledger.include?(START)
  section = ledger[/#{Regexp.escape(START)}(.*?)#{Regexp.escape(STOP)}/m, 1].to_s
  section.each_line do |line|
    next unless line.start_with?("| D")
    cells = line.split("|").map(&:strip)
    cells.shift if cells.first == ""
    existing[norm(cells[1])] = { "id" => cells[0], "status" => cells[5] || "open" }
  end
end

proposals = {}
Dir.glob(File.join(root, "..", ".work", locale, "decisions", "*.md")).sort.each do |path|
  source = File.basename(path, ".md")
  parse_table(path).each do |row|
    key = norm(row["term"])
    next if key.empty? || settled[key]
    entry = proposals[key] ||= {
      "term" => row["term"],
      "proposal" => row["proposal"],
      "alternatives" => [],
      "reason" => row["reason"],
      "sources" => []
    }
    entry["sources"] << source unless entry["sources"].include?(source)
    if entry["proposal"] != row["proposal"]
      entry["alternatives"] << row["proposal"]
    elsif row["alternatives"] && !row["alternatives"].empty?
      entry["alternatives"] << row["alternatives"]
    end
  end
end

lines = []
lines << START
lines << "## Batch proposals"
lines << ""
lines << "Proposed while translating the batches. Same status values as above: agents use the"
lines << "proposal while a row is `open`, and clearing or rejecting it regenerates the affected"
lines << "overrides. Terms already settled above are not repeated."
lines << ""
lines << "| ID | Term | Proposal | Alternatives | Source | Status |"
lines << "|---|---|---|---|---|---|"
proposals.keys.sort.each_with_index do |key, index|
  entry = proposals[key]
  prior = existing[key]
  id = "D#{100 + index}"
  status = prior ? prior["status"] : "open"
  alternatives = entry["alternatives"].uniq.join(", ")
  alternatives = "—" if alternatives.empty?
  reason = entry["reason"].to_s.gsub("|", "/")
  lines << "| #{id} | #{entry["term"]} | #{entry["proposal"]} | #{alternatives} | #{entry["sources"].join(", ")} | #{status} |"
end
lines << ""
lines << STOP
block = lines.join("\n")

if ledger.include?(START)
  ledger = ledger.sub(/#{Regexp.escape(START)}.*?#{Regexp.escape(STOP)}/m, block)
else
  ledger = ledger.rstrip + "\n\n" + block + "\n"
end

File.write(ledger_path, ledger, encoding: "UTF-8")
puts "folded #{proposals.size} proposals from #{Dir.glob(File.join(root, "..", ".work", locale, "decisions", "*.md")).size} files into #{ledger_path}"
