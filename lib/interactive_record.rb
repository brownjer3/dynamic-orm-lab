require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        sql = <<-SQL
        PRAGMA table_info(#{table_name})
        SQL
        result_hash = DB[:conn].execute(sql)
        result_hash.collect do |result|
            result['name']
        end
    end

    def initialize(hash={})
        hash.each do |attribute, value|
            self.send("#{attribute}=", value)
        end
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names[1..-1].join(", ")
    end

    def values_for_insert
        self.class.column_names[1..-1].collect do |c|
            "'#{self.send(c)}'"
        end.join(", ")
    end

    def save
        sql = <<-SQL
        INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
        VALUES (#{values_for_insert})
        SQL
        DB[:conn].execute(sql)
        self.id = DB[:conn].last_insert_row_id()
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT * FROM #{table_name}
        WHERE #{table_name}.name = ?
        LIMIT 1
        SQL
        DB[:conn].execute(sql, name)
    end

    def self.find_by(hash)
        sql = <<-SQL
        SELECT * FROM #{table_name}
        WHERE #{hash.keys.first.to_s} =  ?
        SQL
        DB[:conn].execute(sql, hash.values.first)
    end

end