require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord
  #methods won't be written in this class,

  #except for this method:::
  self.column_names.each do |col_name| #iterate over the column names stored in the column_names class method...
    attr_accessor col_name.to_sym      #...set an attr_accessor for each one, making sure to convert the column name string into a symbol with the #to_sym method, since attr_accessors must be named with symbols
  end

  # This is metaprogramming because we are writing code
  # that writes code for us.
  # By setting the attr_accessors in this way,
  # a reader and writer method for each column name
  # is dynamically created, without us ever having to
  # explicitly name each of these methods.

end
