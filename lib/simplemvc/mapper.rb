require "sqlite3"

module Simplemvc
  class Mapper
    @@db = SQLite3::Database.new(File.join('db', 'app.db'))
    @@table_name = ""
    @@model = nil
    @@mappings = {}

    def save(model)
      @model = model

      if model.id
        @@db.execute(<<SQL, update_record_values)
UPDATE #{@@table_name}
SET
#{update_record_placeholders}
WHERE
id = ?
SQL
      else
        @@db.execute "INSERT INTO #{@@table_name}(#{get_columns}) VALUES(new_record_placholders)", new_record_values
      end
    end

    def method_missing(method, *args)
      @model.send(method)
    end

    def update_record_placeholders
      columns = parse_columns
      columns.map { |col| "#{col}=?" }.join(",") 
    end

    def new_record_placeholders
      (["?"] * (@@mappings.size - 1)).join(",")
    end

    def get_columns
      columns = parse_columns
      columns.join(",")
    end

    def parse_columns
      columns = @@mappings.keys
      columns.delete(:id)
      
      columns
    end

    def get_values
      attributes = @@mappings.values
      attributes.delete(:id)
      attributes.map { |method| send(method) }
    end

    def update_record_values
      get_values << send(:id)
    end

    def new_record_values
      get_values
    end

    def self.findAll
      data = @@db.execute("SELECT #{@@mappings.keys.join(',')} FROM #{@@table_name}")
      data.map do |row|
        map_row_to_object row
      end
    end

    def self.find(id)
      row = @@db.execute("SELECT #{@@mappings.keys.join(',')} FROM #{@@table_name} WHERE id = ?", id).first
      map_row_to_object row
    end

    def delete(id)
      @@db.execute "DELETE FROM #{@@table_name} WHERE id = ?", id
    end

    private

    def self.map_row_to_object(row)
      model = @@model.new

      @@mappings.each_value.with_index do |attribute, index|
        model.send("#{attribute}=", row[index])
      end

      model
    end
  end
end