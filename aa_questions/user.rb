require_relative 'question_database'
require_relative 'question'
require_relative 'reply'
require_relative 'model_base'

class User < ModelBase
  attr_accessor :fname, :lname

  def self.get_table
    "users"
  end

  def self.get_columns
    ["fname", "lname"]
  end

  def self.find_by_name(fname, lname)
    user = QuestionDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ?
        AND lname = ?
    SQL

    return nil if user.empty?
    User.new(user.first)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end

  def average_karma
    karma = QuestionDatabase.instance.execute(<<-SQL, @id)
    SELECT
      -- COUNT(DISTINCT(questions.id)) AS num_questions,
      -- COUNT(question_likes.user_id) AS num_likes,
      -- num_questions / CAST(num_likes AS FLOAT) AS karma
      COUNT(question_likes.user_id) / CAST(COUNT(DISTINCT(questions.id)) AS FLOAT) AS karma
    FROM
      questions
    LEFT JOIN
      question_likes ON questions.id = question_likes.question_id
    WHERE
      questions.author_id = ?
    GROUP BY
      questions.author_id
    SQL
    karma.first['karma']
  end

  # def save
  #   if @id #update
  #     QuestionDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
  #       UPDATE
  #         users
  #       SET
  #         fname = ?, lname = ?
  #       WHERE
  #         id = ?
  #     SQL
  #   else #create
  #     QuestionDatabase.instance.execute(<<-SQL, @fname, @lname)
  #       INSERT INTO
  #         users (fname, lname)
  #       VALUES
  #         (?, ?)
  #     SQL
  #     @id = QuestionDatabase.instance.last_insert_row_id
  #   end
  # end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
end
