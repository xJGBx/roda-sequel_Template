require "bundler/setup"
require_relative "config/settings"
require "sequel_tools"
require "sequel/core"

db = Sequel.connect(Settings.database_url, test: false, keep_reference: false)

namespace :db do
  SequelTools.inject_rake_tasks({
    dbadapter: db.opts[:adapter],
    dbname: db.opts[:database],
    dump_schema_on_migrate: Settings.env == "development",
    schema_location: "db/schema.sql",
    log_level: :info,
    sql_log_level: :info,
  }, self)
end

desc "Open a ruby console with the application loaded"
task :console => :boot do
  require "irb"
  ARGV.clear
  IRB.start
end

desc "Print the database schema"
task :schema do
  # Fetch the list of tables in the database
  tables = db.tables

  # Iterate over each table and print its schema
  tables.each do |table|
    columns = db.schema(table)

    puts "Table: #{table}"
    columns.each do |column|
      puts "  #{column[0]}: #{column[1][:type]}"
    end
    puts
  end
end

desc "View the contents of all tables in the database"
task :view_contents do

  # Fetch the list of tables in the database
  tables = db.tables

  # Iterate over each table and print its contents
  tables.each do |table|
    puts "\nTable: #{table}"

    # Fetch all rows from the table
    rows = db[table].all

    # Print column names
    column_names = db[table].columns
    column_widths = column_names.map { |column| rows.map { |row| row[column].to_s.length }.max }

    # Print formatted column names
    formatted_column_names = column_names.map.with_index { |col, i| col.to_s.ljust(column_widths[i]) }
    puts "  #{formatted_column_names.join(" | ")}"

    # Print a separator line
    separator_line = column_widths.map { |width| "-" * (width + 2) }
    puts "  #{separator_line.join("+")}"

    # Print each row
    rows.each do |row|
      # Print formatted row values
      formatted_values = column_names.map.with_index { |col, i| row[col].to_s.ljust(column_widths[i]) }
      puts "  #{formatted_values.join(" | ")}"
    end
  end
end

task :backup do
  system "pg_dump", db.opts[:database], out: "tmp/backup-#{Date.today.strftime("%Y%m%d")}.sql"
end

task :boot do
  require_relative "config/boot"
end
