require_relative 'question_databse'

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

  def initialize(options)
    @id = options['id']
    @likes = options['likes']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
