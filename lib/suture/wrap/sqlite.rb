require "fileutils"
if defined?(JRUBY_VERSION)
  require "jdbc/sqlite3"
  Jdbc::SQLite3.load_driver
else
  require "sqlite3"
end
require "suture/error/schema_version"

module Suture::Wrap
  module Sqlite
    SCHEMA_VERSION=2
    def self.init(location)
      full_path = File.join(Dir.getwd, location)
      FileUtils.mkdir_p(File.dirname(full_path))
      SQLite3::Database.new(full_path).tap do |db|
        db.execute <<-SQL
          create table if not exists suture_schema_info (
            version integer unique
          );
        SQL
        db.execute("insert or ignore into suture_schema_info values (?)", [SCHEMA_VERSION])
        actual_schema_version = db.execute("select * from suture_schema_info").first[0]
        if SCHEMA_VERSION != actual_schema_version
          raise Suture::Error::SchemaVersion.new(SCHEMA_VERSION, actual_schema_version)
        end

        db.execute <<-SQL
          create table if not exists observations (
            id integer primary key,
            name varchar(255) not null,
            args clob not null,
            result clob,
            error clob,
            unique(name, args)
          );
        SQL
      end
    end

    def self.insert(db, table, cols, vals)
      sql = <<-SQL
        insert into #{table}
          (#{cols.join(", ")})
        values
          (#{vals.size.times.map { "?" }.join(", ")})
      SQL
      db.execute(sql, vals)
    end

    def self.select(db, table, where_clause, bind_params)
      db.execute(
        "select * from #{table} #{where_clause} order by id asc",
        bind_params
      )
    end

    def self.delete(db, table, where_clause, bind_params)
      db.execute("delete from #{table} #{where_clause}", bind_params)
    end
  end
end
