require "suture/wrap/sqlite"

class SqliteWrapTest < SafeTest
  ACTUAL = Suture::Wrap::Sqlite::SCHEMA_VERSION
  DB_PATH = "db/lol.db"

  def test_can_deal_with_multiple_loads
    Suture::Wrap::Sqlite.init(DB_PATH)

    # is happy
    Suture::Wrap::Sqlite.init(DB_PATH)
  end

  def test_major_version_newer
    Suture::Wrap::Sqlite.init(DB_PATH)

    overwrite_schema_version!(992)
    expected_error = assert_raises(Suture::Error::SchemaVersion) {
      Suture::Wrap::Sqlite.init(DB_PATH)
    }
    assert_equal "Your suture gem is too new for this schema. Either delete your database or upgrade the gem (expected schema version 992, was #{ACTUAL})", expected_error.message
  end

  def test_major_version_older
    Suture::Wrap::Sqlite.init(DB_PATH)

    overwrite_schema_version!(-44)
    expected_error = assert_raises(Suture::Error::SchemaVersion) {
      Suture::Wrap::Sqlite.init(DB_PATH)
    }
    assert_equal "Your suture gem is too old for this schema. Either delete your database or downgrade the gem (expected schema version -44, was #{ACTUAL})", expected_error.message
  end

  def overwrite_schema_version!(new_version)
    Suture::Wrap::Sqlite.send(:remove_const, "SCHEMA_VERSION")
    Suture::Wrap::Sqlite.const_set(:SCHEMA_VERSION, new_version)
  end

  def teardown
    super
    Suture::Wrap::Sqlite.send(:remove_const, "SCHEMA_VERSION")
    Suture::Wrap::Sqlite.const_set(:SCHEMA_VERSION, ACTUAL)
  end
end
