class Dog
attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE dogs (
    id INTEGER PRIMARY KEY,
    name TEXT,
    breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def save
      sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs") [0][0]

     self
  end

  def self.create(attribute_hash)
    dog = self.new(attribute_hash)
    dog.save
    dog
  end

  def self.new_from_db(row)
    attribute_hash = {
      :id => row[0],
      :name => row[1],
      :breed => row[2]
    }
    self.new(attribute_hash)
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL

    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    dogs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dogs.empty?
      dog_data = dogs[0]
      dogs = new_from_db(dog_data)
    else
      dogs = self.create(name: name, breed: breed)
    end
    dogs
    
  end

   def find_by_name(name)
     sql = <<-SQL
     SELECT * FROM dogs WHERE name = ?
     SQL
     result = DB[:conn].execute(sql, name)[0]
     Dog.new(result[0], result[1], result[2])
   end




end
