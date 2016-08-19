require "suture/wrap/sqlite"

module Suture::Adapter
  class Dictaphone
    def initialize
      @db = Suture::Wrap::Sqlite.init
    end

    def record(name, args, result)
      Suture::Wrap::Sqlite.insert(@db, :observations, [:name, :args, :result],
                                  [name.to_s, Marshal.dump(args), Marshal.dump(result)])
    end

    def play(name)
      rows = Suture::Wrap::Sqlite.select(@db, :observations, "where name = ?", [name.to_s])
      rows.map do |row|
        Suture::Value::Observation.new(
          row[0],
          row[1].to_sym,
          Marshal.load(row[2]),
          Marshal.load(row[3])
        )
      end
    end
  end
end
