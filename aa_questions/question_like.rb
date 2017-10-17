require_relative 'question_database'
require_relative 'reply'

class QuestionLike
  attr_accessor :likes, :user_id, :question_id

  def self.find_by_id(id)
    question_like = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        quesiton_likes
      WHERE
        id = ?
    SQL

    return nil if question_like.empty?
    QuestionLike.new(question_like.first)
  end

  def self.likers_for_question_id(question_id)
    question_like = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        question_likes
      JOIN users ON users.id = question_likes.user_id
      WHERE
        question_id = ?
    SQL

    question_like.map { |hash| User.new(hash) }
  end

  def self.num_likes_for_question_id(question_id)
    count_arr = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(question_id) AS count
      FROM
        question_likes
      JOIN users ON users.id = question_likes.user_id
      WHERE
        question_id = ?
      GROUP BY
        question_id
    SQL

    count_arr.first["count"]
  end

  def self.liked_questions_for_user_id(user_id)
    question_like = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN question_likes ON question_likes.question_id = questions.id
      WHERE
        user_id = ?
    SQL

    question_like.map { |hash| Question.new(hash) }
  end

  def initialize(options)
    @id = options['id']
    @likes = options['likes']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
