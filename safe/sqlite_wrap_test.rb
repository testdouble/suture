require "suture/wrap/sqlite"

class SqliteWrapTest < SafeTest
  ACTUAL = Suture::Wrap::Sqlite::SCHEMA_VERSION
  DB_PATH = "db/lol.db"

  def test_can_deal_with_multiple_loads
    db = Suture::Wrap::Sqlite.init(DB_PATH)

    # is happy
    db = Suture::Wrap::Sqlite.init(DB_PATH)
  end

  def test_major_version_newer
    db = Suture::Wrap::Sqlite.init(DB_PATH)

    expected_error = nil
    Suture::Wrap::Sqlite.send(:remove_const, "SCHEMA_VERSION")
    Suture::Wrap::Sqlite.const_set("SCHEMA_VERSION", 992)
    begin
      Suture::Wrap::Sqlite.init(DB_PATH)
    rescue Suture::Error::SchemaVersion => e
      expected_error = e
    end
    assert_equal "Your suture gem is too new for this schema. Either delete your database or upgrade the gem (expected schema version 992, was #{ACTUAL})", expected_error.message
  end

  def test_major_version_older
    db = Suture::Wrap::Sqlite.init(DB_PATH)

    expected_error = nil
    Suture::Wrap::Sqlite.send(:remove_const, "SCHEMA_VERSION")
    Suture::Wrap::Sqlite.const_set("SCHEMA_VERSION", -44)
    begin
      Suture::Wrap::Sqlite.init(DB_PATH)
    rescue Suture::Error::SchemaVersion => e
      expected_error = e
    end
    assert_equal "Your suture gem is too old for this schema. Either delete your database or downgrade the gem (expected schema version -44, was #{ACTUAL})", expected_error.message
  end

  def teardown
    Suture::Wrap::Sqlite.send(:remove_const, "SCHEMA_VERSION")
    Suture::Wrap::Sqlite.const_set("SCHEMA_VERSION", ACTUAL)
  end
end

