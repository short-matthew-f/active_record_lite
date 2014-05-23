require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    where_line = params.map { |param| "#{param[0]} = ?" }.join(" AND ")
    
    values = params.map do |param| 
      param[1]
    end
  
    results = DBConnection.execute(<<-SQL, *values
    SELECT *
    FROM #{self.table_name}
    WHERE #{where_line}
    SQL
    )
    
    self.parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
