require "suture/delete"
require "suture/create/builds_plan"
require "suture/adapter/dictaphone"

class DeleteTest < SafeTest
  def test_delete!
    Suture.create(:foo, {
      :old => lambda { "hi" },
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

  def test_delete_all!
    10.times do |i|
      Suture.create(:foo, {
        :old => lambda { |a| a },
        :args => [i],
        :record_calls => true
      })
    end

    Suture.delete_all!(:foo, {
      :database_path => "db/suture.sqlite3"
    })

    rows = Suture::Adapter::Dictaphone.new(Suture::BuildsPlan.new.build(:foo)).play
    assert_equal 0, rows.size
  end
end
