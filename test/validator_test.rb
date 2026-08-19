require "minitest/autorun"
require "open3"
require "pathname"

class ValidatorTest < Minitest::Test
  REPO_ROOT = Pathname.new(__dir__).join("..").expand_path
  SCRIPT = REPO_ROOT.join("scripts/validate.sh")
  SCHEMA_ROOT = REPO_ROOT.join("schemas")
  FIXTURES_ROOT = REPO_ROOT.join("tests/fixtures/validator")

  def test_valid_background_fixture_passes
    stdout, stderr, status = run_fixture("valid-background")

    assert status.success?, "expected success, got #{stderr}"
    assert_includes stdout, "Validated 1 file(s)"
  end

  def test_valid_other_item_fixture_passes
    stdout, stderr, status = run_fixture("valid-other-item")

    assert status.success?, "expected success, got #{stderr}"
    assert_includes stdout, "Validated 1 file(s)"
  end

  def test_valid_class_fixture_passes
    stdout, stderr, status = run_fixture("valid-class")

    assert status.success?, "expected success, got #{stderr}"
    assert_includes stdout, "Validated 1 file(s)"
  end

  def test_valid_school_fixture_passes
    stdout, stderr, status = run_fixture("valid-school")

    assert status.success?, "expected success, got #{stderr}"
    assert_includes stdout, "Validated 1 file(s)"
  end

  def test_valid_feat_fixture_passes
    stdout, stderr, status = run_fixture("valid-feat")

    assert status.success?, "expected success, got #{stderr}"
    assert_includes stdout, "Validated 1 file(s)"
  end

  def test_invalid_feat_type_fails
    _stdout, stderr, status = run_fixture("invalid-feat-type")

    refute status.success?, "expected failure"
    assert_includes stderr, "type"
  end

  def test_missing_source_book_fails
    _stdout, stderr, status = run_fixture("invalid-missing-book")

    refute status.success?, "expected failure"
    assert_includes stderr, "source.book is required"
  end

  def test_schema_failure_reports_data_path
    _stdout, stderr, status = run_fixture("invalid-schema")

    refute status.success?, "expected failure"
    assert_includes stderr, "skillOption"
  end

  def test_name_and_heritage_directory_failures_are_reported_together
    _stdout, stderr, status = run_fixture("invalid-name-and-heritage")

    refute status.success?, "expected failure"
    assert_includes stderr, "filename slug"
    assert_includes stderr, "heritage ancestry"
  end

  def test_utf16_fixture_fails
    _stdout, stderr, status = run_fixture("invalid-utf16")

    refute status.success?, "expected failure"
    assert_includes stderr, "UTF-8"
  end

  private

  def run_fixture(name)
    root = FIXTURES_ROOT.join(name)
    Open3.capture3(
      SCRIPT.to_s,
      "--root", root.to_s,
      "--schema-root", SCHEMA_ROOT.to_s
    )
  end
end
