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

  def test_core_mechanics_descriptor_is_deterministic_and_well_formed
    path = File.join(ROOT, "mechanics", "org.openomen.pf2e.core.json")
    descriptor = JSON.parse(File.read(path))

    assert_equal "org.openomen.pf2e.core", descriptor.fetch("moduleID")
    assert_equal 1, descriptor.fetch("revision")
    assert_equal [], descriptor.fetch("dependencies")
    assert_equal 24, descriptor.fetch("valueTypes").length
    assert_equal 27, descriptor.fetch("effects").length
    assert_equal 0, descriptor.fetch("stateKeys").length
    assert_equal File.read(path), JSON.generate(descriptor, quirks_mode: true) + "\n",
                 "descriptor must use canonical sorted-key JSON"
  end

  def test_publication_declares_exact_mechanics_modules
    publication_path = File.join(ARCHIVE_ROOT, "publication.yml")
    publication = YAML.safe_load(File.read(publication_path), aliases: true)

    assert_equal [
      { "moduleID" => "org.openomen.pf2e.core", "revision" => 1 }
    ], publication.fetch("mechanicsModules")
    refute publication.key?("mechanicsDependencies")
  end

  def test_all_rule_files_use_registry_wire_shape
    paths = Dir[File.join(ARCHIVE_ROOT, "**", "*.yml")]
    rule_files = paths.select do |path|
      YAML.safe_load(File.read(path), aliases: true).is_a?(Hash) &&
        YAML.safe_load(File.read(path), aliases: true).key?("rules")
    end
    assert_equal 98, rule_files.length
    literal_payloads = []
    rule_files.each do |path|
      rules = YAML.safe_load(File.read(path), aliases: true).fetch("rules")
      rules.each do |rule|
        refute rule.key?("effectTemplate"), path
        assert_match(%r{\A[a-z0-9.-]+/effect/[a-z0-9-]+\z}, rule.fetch("effectReference").fetch("kindID"), path)
        rule.fetch("inputRecipes").each do |recipe|
          expected = recipe.fetch("expectedValue")
          assert_match(%r{\A[a-z0-9.-]+/value/[a-z0-9-]+\z}, expected.fetch("valueTypeID"), path)
          source = expected.fetch("source")
          assert source.key?("kind"), path
          literal_payloads << [expected.fetch("valueTypeID"), source.fetch("value").fetch("payload")] if source["kind"] == "literal"
        end
      end
    end

    value_prefix = "org.openomen.pf2e.core/value/"
    assert_includes literal_payloads, [value_prefix + "skill", { "kind" => "religion" }]
    assert_includes literal_payloads, [value_prefix + "weapon-group", "any"]
    assert_includes literal_payloads, [value_prefix + "weapon-designation", {
      "kind" => "filter", "weaponKind" => "advanced", "weaponGroup" => "any"
    }]
    assert_includes literal_payloads, [value_prefix + "weapon-designation", { "kind" => "specific", "name" => "club" }]
  end
end
