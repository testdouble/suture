require "suture/wrap/sqlite"
require "suture/error/observation_conflict"

module Suture::Adapter
  class Dictaphone
    def initialize
      @db = Suture::Wrap::Sqlite.init
    end

    def record(name, args, result)
      Suture::Wrap::Sqlite.insert(@db, :observations, [:name, :args, :result],
                                  [name.to_s, Marshal.dump(args), Marshal.dump(result)])

    rescue SQLite3::ConstraintException => e
      old_result = result_for(name, args)
      if old_result != result # TODO - use comparator
        raise Suture::Error::ObservationConflict.new(name, args, result, old_result)
      else
        # We're all good here, it was just a duplicative observation. No harm.
      end
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

  private

    def result_for(name, args)
      rows = Suture::Wrap::Sqlite.select(
        @db,
        :observations,
        "where name = ? and args = ?",
        [name.to_s, Marshal.dump(args)]
      )
      Marshal.load(rows.first[3])
    end
  end
end
