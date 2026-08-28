require "digest"
require "json"
require "minitest/autorun"
require "yaml"

class PlayerCoreCorpusTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  MANIFEST_PATH = File.join(ROOT, "docs", "player-core-corpus-manifest.json")
  SOURCE_ROOT = File.expand_path("../pf2e", ROOT)
  ARCHIVE_ROOT = File.join(ROOT, "src", "paizo-pathfinder-player-core")

  def setup
    @manifest = JSON.parse(File.read(MANIFEST_PATH))
    @records = @manifest.fetch("records")
  end

  def test_manifest_counts_and_source_hashes_are_stable
    assert_equal "4cbdaa37d6c33e9519561bae2c59a23e0288cbce", @manifest.fetch("pf2eRevision")
    assert_equal 1_938, @records.length
    assert_equal({
      "action" => 107,
      "ancestry" => 8,
      "ancestry-feature" => 2,
      "background" => 40,
      "class" => 8,
      "class-feature" => 166,
      "feat" => 849,
      "heritage" => 49,
      "item" => 221,
      "spell" => 488
    }, @manifest.fetch("totals").fetch("byResourceType"))
    assert_equal({
      "ancestry" => 186,
      "class" => 537,
      "general" => 20,
      "skill" => 106
    }, @manifest.fetch("totals").fetch("byFeatCategory"))
    assert_equal @records.length, @records.map { |record| record.fetch("foundryID") }.uniq.length

    @records.each do |record|
      assert_match(/\A[0-9a-f]{64}\z/, record.fetch("sourceHash"), record.fetch("name"))
      refute_empty record.fetch("sourcePath")
      refute_empty record.fetch("canonicalPath")
    end

    skip "Pinned pf2e checkout is unavailable for source hash verification" unless Dir.exist?(SOURCE_ROOT)

    @records.each do |record|
      source_path = File.join(SOURCE_ROOT, record.fetch("sourcePath"))
      assert File.file?(source_path), "missing source record: #{source_path}"
      assert_equal Digest::SHA256.file(source_path).hexdigest, record.fetch("sourceHash"),
                   "source hash drifted for #{record.fetch("name")}"
    end
  end

  def test_all_feats_and_features_have_canonical_provenance
    feat_records = @records.select { |record| record.fetch("resourceType") == "feat" }
    feat_files = Dir[File.join(ARCHIVE_ROOT, "feat", "*.yml")]
    feat_payloads = feat_files.map { |path| [path, YAML.safe_load(File.read(path), aliases: true)] }
    feat_ids = feat_payloads.map { |_path, payload| payload.fetch("sourceID") }

    assert_equal feat_records.length, feat_files.length
    assert_equal feat_records.map { |record| record.fetch("foundryID") }.sort, feat_ids.sort

    feature_records = @records.select { |record| ["class-feature", "ancestry-feature"].include?(record.fetch("resourceType")) }
    feature_files = Dir[File.join(ARCHIVE_ROOT, "class", "**", "features", "*.yml")] +
      Dir[File.join(ARCHIVE_ROOT, "ancestry", "**", "features", "*.yml")]
    feature_ids = feature_files.map { |path| YAML.safe_load(File.read(path), aliases: true).fetch("sourceID") }.uniq

    assert_equal feature_records.map { |record| record.fetch("foundryID") }.sort, feature_ids.sort
    assert feature_files.all? { |path| YAML.safe_load(File.read(path), aliases: true).fetch("sourceID") },
           "every generated feature must retain source provenance"
  end
end
