require "json"
require "minitest/autorun"
require "yaml"

class PlayerCoreSpellImportTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  MANIFEST_PATH = File.join(ROOT, "docs", "player-core-spell-import-manifest.json")

  def setup
    @manifest = JSON.parse(File.read(MANIFEST_PATH))
    @records = @manifest.fetch("records")
  end

  def test_manifest_accounts_for_every_expected_player_core_spell
    assert_equal 488, @manifest.fetch("expected_count")
    assert_equal 465, @manifest.fetch("generated_count")
    assert_equal 23, @manifest.fetch("reviewed_skip_count")
    assert_equal({
      "spell" => 298,
      "cantrip" => 41,
      "focus" => 130,
      "ritual" => 19
    }, @manifest.fetch("category_counts"))
    skip_reasons = @records
      .select { |record| record.fetch("status") == "reviewed-skip" }
      .map { |record| record.fetch("skip_reason") }
    assert_equal 18, skip_reasons.count { |reason| reason.include?("overlays") }
    assert_equal 2, skip_reasons.count { |reason| reason.include?("rule elements") }
    assert_equal 3, skip_reasons.count { |reason| reason.include?("fixed heightening") }
    assert_equal @manifest.fetch("expected_count"), @records.length
    assert_equal @records.length, @records.map { |record| record.fetch("source_id") }.uniq.length
  end

  def test_generated_files_and_reviewed_skips_are_explicit
    generated = @records.select { |record| record.fetch("status") == "generated" }
    skipped = @records.select { |record| record.fetch("status") == "reviewed-skip" }

    generated.each do |record|
      path = File.join(ROOT, record.fetch("archive_file"))
      assert File.file?(path), "missing generated spell YAML: #{path}"
      text = File.read(path)
      refute_match(/@[A-Za-z][\w]*\[/, text, "unsanitized Foundry macro in #{path}")
      refute_match(/\[\[(?:\/r|\/gmr)\b/, text, "unsanitized Foundry inline roll in #{path}")
      refute_match(/<[^>]+>/, text, "HTML tag in #{path}")
      payload = YAML.safe_load(text)
      assert_equal record.fetch("source_id"), payload.fetch("sourceID"),
                   "archive provenance mismatch in #{path}"
      assert_equal "Pathfinder Player Core", payload.fetch("source").fetch("book")
    end

    skipped.each do |record|
      refute_empty record.fetch("skip_reason"), "reviewed skip needs a reason: #{record["name"]}"
    end

    spell_root = File.join(ROOT, "src", "paizo-pathfinder-player-core", "spell")
    actual_paths = Dir[File.join(spell_root, "*.yml")].map { |path| path.delete_prefix(ROOT + "/") }.sort
    assert_equal generated.map { |record| record.fetch("archive_file") }.sort, actual_paths
  end
end
