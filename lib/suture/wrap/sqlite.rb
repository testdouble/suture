require "fileutils"
require "sqlite3"

module Suture::Wrap
  module Sqlite
    def self.init
      FileUtils.mkdir_p(File.join(Dir.getwd, "db"))
      SQLite3::Database.new("db/suture.sqlite3").tap do |db|
        db.execute <<-SQL
          create table if not exists observations (
            id integer primary key,
            name varchar(255),
            args clob,
            result clob
          );
        SQL
      end
    end

    def self.insert(db, table, cols, vals)
      db.execute("insert into #{table} (#{cols.join(", ")}) values (?,?,?)", vals)
    end

    def self.select(db, table, where_clause, bind_params)
      db.execute("select * from #{table} #{where_clause}", bind_params)
    end
  end
end
