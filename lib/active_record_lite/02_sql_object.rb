require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    # ...
  end
end

class SQLObject < MassObject
  def self.columns
    col_names = DBConnection.execute2("SELECT * FROM cats").first
    col_names.each do |name|
      define_method("#{name}") do
        self.instance_variable_get("@#{name}")
      end
      
      define_method("#{name}=") do |value|
        self.instance_variable_set("@#{name}", value)
      end      
    end
    col_names
  end

  def self.table_name=(table_name)
    self.instance_variable_set("@table_name", table_name)
  end

  def self.table_name
    name = self.instance_variable_get("@table_name")
    if name
      name
    else
      self.to_s.tableize
    end
  end

  def self.parse_all(hashes)
    objects = []
    hashes.each do |hash|
      current = self.new
      hash.each do |k, v|
        current.instance_variable_set("@#{k}", "#{v}")
      end
      objects << current
    end
    objects
  end

  def self.all
    # ...
  end

  def self.find(id)
    # ...
  end

  def attributes
    current = self.instance_variable_get("@attributes") || 
      self.instance_variable_set("@attributes", Hash.new)

    current
  end

  def insert
    # ...
  end

  def initialize(params)
    params.each do |attr_name, value|
      
    end
  end

  def save
    # ...
  end

  def update
    # ...
  end

  def attribute_values
    current = self.instance_variable_get("@attributes")
    
    current.values
  end
end
