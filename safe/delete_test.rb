require "suture/create/builds_plan"
require "suture/adapter/dictaphone"

class DeleteTest < SafeTest
  def test_delete
    Suture.create(:foo, {
      :old => lambda { 'hi' },
      :args => [],
      :record_calls => true,
      :database_path => "db/lol.db"
    })
    rows = Suture::Adapter::Dictaphone.new(Suture::BuildsPlan.new.build(:foo, {
      :database_path => "db/lol.db"
    })).play

    Suture.delete!(rows.first.id, {
      :database_path => "db/lol.db"
    })

    rows = Suture::Adapter::Dictaphone.new(Suture::BuildsPlan.new.build(:foo, {
      :database_path => "db/lol.db"
    })).play
    assert_equal 0, rows.size
  end
end
