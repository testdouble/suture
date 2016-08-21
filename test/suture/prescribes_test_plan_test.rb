class PrescribesTestPlanTest < Minitest::Test
  def setup
    @subject = Suture::PrescribesTestPlan.new
  end

  def teardown
    ENV.delete_if { |(k,v)| k.start_with?("SUTURE_") }
    Suture.reset!
  end

  def test_defaults
    result = @subject.prescribe(:foo)

    assert_equal :foo, result.name
    assert_equal true, result.fail_fast
    assert_equal "db/suture.sqlite3", result.database_path
    assert_kind_of Suture::Comparator, result.comparator
  end

  def test_global_overrides
    Suture.config(
      :database_path => "other.db",
      :comparator => :lolcompare
    )

    result = @subject.prescribe(:foo)

    assert_equal "other.db", result.database_path
    assert_equal :lolcompare, result.comparator
  end

  def test_options
    some_subject = lambda {}

    result = @subject.prescribe(:foo,
      :database_path => "db",
      :subject => some_subject,
      :args => [:lol],
      :fail_fast => false,
      :comparator => :lol_compare
    )

    assert_equal :foo, result.name
    assert_equal some_subject, result.subject
    assert_equal [:lol], result.args
    assert_equal false, result.fail_fast
    assert_equal "db", result.database_path
    assert_equal :lol_compare, result.comparator
  end

  def test_env_vars
    ENV['SUTURE_NAME'] = 'bad name'
    ENV['SUTURE_SUBJECT'] = 'sub'
    ENV['SUTURE_ARGS'] = 'nope'
    ENV['SUTURE_DATABASE_PATH'] = 'd'
    ENV['SUTURE_COMPARATOR'] = 'e'
    ENV['SUTURE_FAIL_FAST'] = 'false'

    result = @subject.prescribe(:a_name)

    assert_equal "d", result.database_path
    assert_equal false, result.fail_fast
    # options that can't be set with ENV vars:
    assert_equal :a_name, result.name
    assert_equal nil, result.subject
    assert_equal nil, result.args
    assert_kind_of Suture::Comparator, result.comparator
  end
end
