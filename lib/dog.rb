require 'pry'


class Dog
    attr_accessor :name, :breed, :id

    def initialize name:,breed:,id:nil
        @name = name
        @breed = breed
        @id = id
    end
    
    def self.create_table
        query = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(169), breed TEXT NOT NULL)
        SQL
        DB[:conn].query(query)
    end
    
    def self.drop_table
        query = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].query(query)
    end
    
    def save
        query = <<-SQL
        INSERT INTO dogs (name,breed) VALUES (?,?)
        SQL
    
        DB[:conn].query(query,self.name,self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    
    def self.create name:,breed:,id:nil
        dog = self.new(name:name,breed:breed,id:id)
        dog.save
        dog
    end
    
    def self.new_from_db row
        self.new(id:row[0],name:row[1],breed:row[2])
    end
    
    def self.all
        sql = <<-SQL
        SELECT *
          FROM dogs
        SQL
    
        DB[:conn].execute(sql).map do |row|
          self.new_from_db(row)
        end
    end
    
    def self.find_by_name name
        query = <<-SQL
        SELECT * FROM dogs WHERE name=? LIMIT 1
        SQL
        row = DB[:conn].execute(query,name)
        self.new_from_db row[0]
    end
    
    def self.find id
        query = <<-SQL
        SELECT * FROM dogs WHERE id=? LIMIT 1
        SQL
        row = DB[:conn].execute(query,id)
        self.new_from_db row[0]
    end
    
    def self.find_or_create_by name:,breed:
        query = <<-SQL
        SELECT * FROM dogs WHERE name=? AND breed=? LIMIT 1
        SQL
        row = DB[:conn].execute(query,name,breed)
        if(row.length>0)
            self.new_from_db row[0]
        else
            create(name:name,breed:breed)
        end
    end
    
    def update
        query = <<-SQL
        UPDATE dogs SET name = ?, breed = ?
        WHERE id = ?
        SQL
    
        DB[:conn].query(query,self.name,self.breed,self.id)
    end
end
