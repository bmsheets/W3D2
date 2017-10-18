require_relative 'question_database'
require_relative 'reply'
require_relative 'model_base'

class Question < ModelBase
  attr_accessor :title, :body, :author_id

  def self.get_table
    "questions"
  end

  def self.find_by_author_id(author_id)
    question = QuestionDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id = ?
    SQL

    return nil if question.empty?
    Question.new(question.first)
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end



  def replies
    Reply.find_by_question_id(@id)
  end

  def author
    User.find_by_id(@author_id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  # def names_of_likers
  #   likers.map { |user| [user.fname, user.lname] }
  # end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def most_liked(n)
    QuestionLike.most_liked_questions(n)
  end

  def save
    if @id #update
      QuestionDatabase.instance.execute(<<-SQL, @title, @body, @author_id, @id)
        UPDATE
          questions
        SET
          title = ?, body = ?, author_id
        WHERE
          id = ?
      SQL
    else #create
      QuestionDatabase.instance.execute(<<-SQL, @title, @body, @author_id)
        INSERT INTO
          questions (title, body, author_id)
        VALUES
          (?, ?, ?)
      SQL
      @id = QuestionDatabase.instance.last_insert_row_id
    end
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end
end
