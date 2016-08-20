require "suture/wrap/sqlite"

class SqliteWrapTest < SafeTest
  ACTUAL = Suture::Wrap::Sqlite::SCHEMA_VERSION

  def test_can_deal_with_multiple_loads
    db = Suture::Wrap::Sqlite.init

    # is happy
    db = Suture::Wrap::Sqlite.init
  end

  def test_major_version_newer
    db = Suture::Wrap::Sqlite.init

    expected_error = nil
    Suture::Wrap::Sqlite.send(:remove_const, "SCHEMA_VERSION")
    Suture::Wrap::Sqlite.const_set("SCHEMA_VERSION", 992)
    begin
      Suture::Wrap::Sqlite.init
    rescue Suture::Error::SchemaVersion => e
      expected_error = e
    end
    assert_equal "Your suture gem is too new for this schema. Either delete your database or upgrade the gem (expected schema version 992, was #{ACTUAL})", expected_error.message
  end

  def test_major_version_older
    db = Suture::Wrap::Sqlite.init

    expected_error = nil
    Suture::Wrap::Sqlite.send(:remove_const, "SCHEMA_VERSION")
    Suture::Wrap::Sqlite.const_set("SCHEMA_VERSION", -44)
    begin
      Suture::Wrap::Sqlite.init
    rescue Suture::Error::SchemaVersion => e
      expected_error = e
    end
    assert_equal "Your suture gem is too old for this schema. Either delete your database or downgrade the gem (expected schema version -44, was #{ACTUAL})", expected_error.message
  end

  def test_unique_calls
    db = Suture::Wrap::Sqlite.init
    Suture::Wrap::Sqlite.insert(db, :observations, [:name, :args, :result],
                                ["foo", Marshal.dump([1]), Marshal.dump(:old)])

    
    Suture::Wrap::Sqlite.insert(db, :observations, [:name, :args, :result],
                                ["foo", Marshal.dump([1]), Marshal.dump(:new)])

    result = Suture::Wrap::Sqlite.select(db, :observations, "", [])

    assert_equal 1, result.size
    assert_equal :new, Marshal.load(result[0][3])
  end

  def teardown
    Suture::Wrap::Sqlite.send(:remove_const, "SCHEMA_VERSION")
    Suture::Wrap::Sqlite.const_set("SCHEMA_VERSION", ACTUAL)
  end
end

