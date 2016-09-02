require "suture/wrap/sqlite"
require "suture/adapter/log"
require "suture/value/observation"
require "suture/value/result"
require "suture/error/observation_conflict"
require "suture/util/compares_results"

module Suture::Adapter
  class Dictaphone
    include Suture::Adapter::Log

    def initialize(plan)
      @db = Suture::Wrap::Sqlite.init(plan.database_path)
      @name = plan.name
      @compares_results = Suture::Util::ComparesResults.new(plan.comparator)
      if plan.respond_to?(:args) # does not apply to TestPlan objects
        @args_inspect = plan.args.inspect
        @args_dump = Marshal.dump(plan.args)
      end
    end


    def record(returned_value)
      record_result(Suture::Value::Result.returned(returned_value))
    end

    def record_error(error)
      record_result(Suture::Value::Result.errored(error))
    end

    def play(only_id = nil)
      rows = Suture::Wrap::Sqlite.select(
        @db, :observations,
        "where name = ? #{"and id = ?" if only_id}",
        [@name.to_s, only_id].compact
      )
      log_debug("found #{rows.size} recorded calls for seam #{@name.inspect}.")
      rows.map { |row| row_to_observation(row) }
    end

    def delete_by_id!(id)
      log_info("deleting call with ID: #{id}")
      Suture::Wrap::Sqlite.delete(@db, :observations, "where id = ?", [id])
    end

    def delete_by_name!(name)
      log_info("deleting calls for seam named: #{name}")
      Suture::Wrap::Sqlite.delete(@db, :observations, "where name = ?", [name.to_s])
    end

  private

    def record_result(result)
      Suture::Wrap::Sqlite.insert(
        @db,
        :observations,
        [:name, :args, result.errored? ? :error : :result],
        [@name.to_s, @args_dump, Marshal.dump(result.value)]
      )
      log_info("recorded call for seam #{@name.inspect} with args `#{@args_inspect}` and result `#{result.value.inspect}`")
    rescue SQLite3::ConstraintException
      old_observation = known_observation
      if @compares_results.compare(old_observation.result, result)
        log_debug("skipped recording of duplicate call for seam #{@name.inspect} with args `#{@args_inspect}` and result `#{result.value.inspect}`")
      else
        raise Suture::Error::ObservationConflict.new(@name, @args_inspect, result, old_observation)
      end
    end

    def row_to_observation(row)
      Suture::Value::Observation.new(
        :id => row[0],
        :name => row[1].to_sym,
        :args => Marshal.load(row[2]),
        :return => row[3] ? Marshal.load(row[3]) : nil,
        :error => row[4] ? Marshal.load(row[4]) : nil
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
