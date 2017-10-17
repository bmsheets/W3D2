require_relative 'question_database'
require_relative 'reply'

class Question
  attr_accessor :title, :body, :author_id
  def self.find_by_id(id)
    question = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL

    return nil if question.empty?
    Question.new(question.first)
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

  def replies
    Reply.find_by_question_id(@id)
  end

  def author
    User.find_by_id(@author_id)
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end
end
