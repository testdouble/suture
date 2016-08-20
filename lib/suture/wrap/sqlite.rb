require "fileutils"
require "sqlite3"
require "suture/error/schema_version"

module Suture::Wrap
  module Sqlite
    SCHEMA_VERSION=1
    def self.init
      FileUtils.mkdir_p(File.join(Dir.getwd, "db"))
      SQLite3::Database.new("db/suture.sqlite3").tap do |db|
        db.execute <<-SQL
          create table if not exists schema_info (
            version integer unique
          );
        SQL
        db.execute("insert or ignore into schema_info values (?)", [SCHEMA_VERSION])
        actual_schema_version = db.execute("select * from schema_info").first[0]
        if SCHEMA_VERSION != actual_schema_version
          raise Suture::Error::SchemaVersion.new(SCHEMA_VERSION, actual_schema_version)
        end

        db.execute <<-SQL
          create table if not exists observations (
            id integer primary key,
            name varchar(255),
            args clob,
            result clob,
            unique(name, args) on conflict abort
          );
        SQL
      end
    end

    def self.insert(db, table, cols, vals)
      db.execute("insert into #{table} (#{cols.join(", ")}) values (?,?,?)", vals)
    rescue SQLite3::ConstraintException => e
      raise Suture::Error::ConflictingCharacterization.new()
    end

    def self.select(db, table, where_clause, bind_params)
      db.execute("select * from #{table} #{where_clause}", bind_params)
    end
  end
end
