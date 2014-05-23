require_relative '03_searchable'
require 'active_support/inflector'

# Phase IVa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || 
      (name.to_s.downcase + "_id").to_sym
    @class_name = options[:class_name] || 
      name.to_s.capitalize
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || 
      (self_class_name.to_s.downcase + "_id").to_sym
    @class_name = options[:class_name] || 
      name.to_s.capitalize.singularize
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  # Phase IVb
  def belongs_to(name, options = {})  
    define_method(name) do
      options = BelongsToOptions.new(name, options)
      
      foreign_id = self.send(options.foreign_key)
      model_class = options.model_class
      
      model_class.where(options.primary_key => foreign_id).first
    end
  end

  def has_many(name, options = {})
    my_name = self.to_s
    
    define_method(name) do 
      options = HasManyOptions.new(name, my_name, options)
      
      foreign_id = self.send(options.primary_key)
      
      options.model_class.where(options.foreign_key => foreign_id)  
    end
  end

  def assoc_options
    # Wait to implement this in Phase V. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end

