require 'sqlite3'

DB = {:conn => SQLite3::Database.new("db/students.db")}
DB[:conn].execute("DROP TABLE IF EXISTS students")

sql = <<-SQL
  CREATE TABLE IF NOT EXISTS students (
  id INTEGER PRIMARY KEY,
  name TEXT,
  grade INTEGER
  )
SQL

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true

#results_as_hash method, available to use
#from the SQLite3-Ruby gem. 
#This method says: when a SELECT statement is executed,
# don't return a database row as an array,
# return it as a hash with the column names as keys.
