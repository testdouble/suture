require "suture/wrap/sqlite"
require "suture/adapter/log"
require "suture/value/observation"
require "suture/error/observation_conflict"

module Suture::Adapter
  class Dictaphone
    include Suture::Adapter::Log

    def initialize(plan)
      @db = Suture::Wrap::Sqlite.init(plan.database_path)
      @name = plan.name
      @comparator = plan.comparator
      if plan.respond_to?(:args) # does not apply to TestPlan objects
        @args_inspect = plan.args.inspect
        @args_dump = Marshal.dump(plan.args)
      end
    end

    def record(result)
      Suture::Wrap::Sqlite.insert(@db, :observations, [:name, :args, :result],
                                  [@name.to_s, @args_dump, Marshal.dump(result)])
      log_info("recorded call for seam #{@name.inspect} with args `#{@args_inspect}` and result `#{result.inspect}`")
    rescue SQLite3::ConstraintException => e
      old_observation = known_observation
      if @comparator.call(old_observation.result, result)
        log_debug("skipped recording of duplicate call for seam #{@name.inspect} with args `#{@args_inspect}` and result `#{result.inspect}`")
      else
        raise Suture::Error::ObservationConflict.new(@name, @args_inspect, result, old_observation)
      end
    end

    def play(only_id = nil)
      rows = if only_id
        Suture::Wrap::Sqlite.select(@db, :observations, "where name = ? and id = ?", [@name.to_s, only_id])
      else
        Suture::Wrap::Sqlite.select(@db, :observations, "where name = ?", [@name.to_s])
      end
      log_debug("found #{rows.size} recorded calls for seam #{@name.inspect}.")
      rows.map do |row|
        Suture::Value::Observation.new(
          row[0],
          row[1].to_sym,
          Marshal.load(row[2]),
          Marshal.load(row[3])
        )
      end
    end

    def delete(id)
      log_info("deleting call with ID: #{id}")
      Suture::Wrap::Sqlite.delete(@db, :observations, "where id = ?", [id])
    end

  private

    def row_to_observation(row)
      Suture::Value::Observation.new(
        row[0],
        row[1].to_sym,
        Marshal.load(row[2]),
        Marshal.load(row[3])
      )
    end

    def known_observation
      row_to_observation(Suture::Wrap::Sqlite.select(
        @db,
        :observations,
        "where name = ? and args = ?",
        [@name.to_s, @args_dump]
      ).first)
    end
  end
end
