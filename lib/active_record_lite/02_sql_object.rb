require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map do |result|
      self.new(
        Hash[ result.map { |k,v| [k.to_sym, v] } ]
      )
    end
  end
end

class SQLObject < MassObject
  def self.columns
    if @columns.nil?
      @columns = []
      
      DBConnection.execute2("SELECT * FROM #{self.table_name}")
        .first
        .each do |name|
        
        name = name.to_sym  
          
        define_method(name) do
          self.attributes[name]
        end
      
        define_method("#{name}=") do |value|
          self.attributes[name] = value
        end 
               
        @columns << name
      end
    end
    
    return @columns
  end

  def self.table_name=(table_name)
    self.instance_variable_set("@table_name", table_name)
  end

  def self.table_name
    @table_name || self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL
    SELECT *
    FROM #{self.table_name}
    SQL
    )
    
    self.parse_all(results)
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id
    SELECT *
    FROM #{self.table_name}
    WHERE #{self.table_name}.id = ?
    SQL
    )

    self.parse_all(results).first    
  end

  def attributes
    @attributes ||= {}
  end

  def insert     
    cols = self.class.columns - (self.id ? [] : [:id])
    
    column_string = cols.join(', ')
    value_string = cols.map { |col| "'#{self.send(col)}'" }.join(', ')
    
    DBConnection.execute(<<-SQL)
    INSERT INTO #{self.class.table_name} (#{column_string})
    VALUES (#{value_string})
    SQL
    
    self.id = DBConnection.last_insert_row_id
  end

  def initialize(params = {})
    valid_columns = self.class.columns
    
    params.each do |attr_name, value|
      unless valid_columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'" 
      end
      
      attributes[attr_name] = value
    end
  end

  def save
    if id.nil?
      self.insert
    else
      self.update
    end
  end

  def update
    cols = self.class.columns - [:id]
    
    set_string = cols.map { |col| "#{col} = ?"}.join(', ')
    values = cols.map { |col| self.send(col) }
    
    DBConnection.execute(<<-SQL, *values)
    UPDATE #{self.class.table_name} 
    SET
      #{set_string}
    WHERE
      id = #{self.id}
    SQL
  end

  def attribute_values
    attributes.values
  end
end
