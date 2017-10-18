class ModelBase

  def self.find_by_id(id)
    table = self.get_table
    reply = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{table}
      WHERE
        id = ?
    SQL

    return nil if reply.empty?
    self.new(reply.first)
  end

  def self.all
    table = self.get_table
    data = QuestionDatabase.instance.execute("SELECT * FROM #{table}")
    data.map { |datum| self.new(datum) }
  end

  def self.where(options)
    table = self.get_table
    data = QuestionDatabase.instance.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table}
      WHERE
        #{generate_where_clause(options)}
    SQL
    data.map { |datum| self.new(datum) }
  end

  def self.generate_where_clause(hash)
    clause = []
    hash.each do |column, value|
      clause << "#{column} = #{value}"
    end
    clause.join(" AND ")
  end

  def initialize
  end

  def save
    table = self.class.get_table
    columns = self.class.get_columns
    q_marks = []
    columns.length.times do
      q_marks << "?"
    end
    vars = self.instance_variables.reject { |el| el == :@id }
    vars << :@id
    p vars
    string_vars = vars.map do |var|
      var.to_s
    end
    set_vars = vars.map do |var|
      var.to_s[1..-1]
    end
    p set_vars
    set_vars.pop
    set_string = set_vars.join(" = ?, ") + " = ?"
    p set_string
    if @id #update
      QuestionDatabase.instance.execute(<<-SQL, string_vars)
        UPDATE
          #{table}
        SET
          #{set_string}
        WHERE
          id = ?
      SQL
    else #create
      vars.pop
      QuestionDatabase.instance.execute(<<-SQL, string_vars)
        INSERT INTO
          #{table} (#{columns.join(', ')})
        VALUES
          (#{q_marks.join(', ')})
      SQL
      @id = QuestionDatabase.instance.last_insert_row_id
    end
  end

end
