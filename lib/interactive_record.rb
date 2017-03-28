require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name #grabs us the table name we want to query for column names
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "pragma table_info('#{table_name}')" #SQL query to return an array of hashes describing the table (thanks to results_as_hash method)
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |column| #iterate over the resulting array of hashes...
      column_names << column["name"] #...to collect just the name of each column
    end
    column_names.compact #call #compact on column_names to get rid of any nil values
  end

##### why does this method go in the child instead of the parent? ######
  # self.column_names.each do |col_name| #iterate over the column names stored in the column_names class method...
  #   attr_accessor col_name.to_sym      #...set an attr_accessor for each one, making sure to convert the column name string into a symbol with the #to_sym method, since attr_accessors must be named with symbols
  # end

  def initialize(options={}) #define method to take in an argument of options, which defaults to an empty hash
    options.each do |property, value|  #iterate over the options hash...
      self.send("#{property}=", value) #and use our fancy metaprogramming #send method to interpolate the name of each hash key as a method that we set equal to that key's value
    end
  end

  #conventional ORM methods below:::

  def table_name_for_insert
    self.class.table_name #inside an instance method, self will refer to the instance of the class, not the class itself
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ") #need to remove "id" from the array of column names returned, cuz our SQL database handles the creation of an ID for a given table row and then we will use that ID to assign a value to the original object's id attribute
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil? #push the return value of invoking a method via the #send method, unless that value is nil (as it would be for the id method before a record is saved, for instance)
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

#got this from github cuz couldn't figure it out:::
  def self.find_by(attribute_hash)
    value = attribute_hash.values.first
    formatted_value = value.class == Fixnum ? value : "'#{value}'"
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute_hash.keys.first} = #{formatted_value}"
    DB[:conn].execute(sql)
  end

end
