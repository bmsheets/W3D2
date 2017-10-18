require_relative 'question_database'
require_relative 'user'
require_relative 'question'
require_relative 'model_base'

class Reply < ModelBase
  attr_accessor :question_id, :reply_id, :user_id, :body

  def self.get_table
    "replies"
  end

  def self.find_by_user_id(user_id)
    reply = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL

    return nil if reply.empty?
    Reply.new(reply.first)
  end

  # Covers all depth?
  def self.find_by_question_id(question_id)
    reply = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL

    return nil if reply.empty?
    Reply.new(reply.first)
  end

  def author
    User.find_by_id(@user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Reply.find_by_user_id(@reply_id)
  end

  def child_replies
    reply = QuestionDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        reply_id = ?
    SQL

    return nil if reply.empty?
    Reply.new(reply.first)
  end

  def save
    if @id #update
      QuestionDatabase.instance.execute(<<-SQL, @question_id, @reply_id, @user_id, @body, @id)
        UPDATE
          replies
        SET
          question_id = ?, reply_id = ?, user_id = ?, body = ?
        WHERE
          id = ?
      SQL
    else #create
      QuestionDatabase.instance.execute(<<-SQL, @question_id, @reply_id, @user_id, @body)
        INSERT INTO
          replies (question_id, reply_id, user_id, body)
        VALUES
          (?, ?, ?, ?)
      SQL
      @id = QuestionDatabase.instance.last_insert_row_id
    end
  end


  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @reply_id = options['reply_id']
    @user_id = options['user_id']
    @body = options['body']
  end
end
