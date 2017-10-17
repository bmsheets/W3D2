require_relative 'question_databse'

class QuestionFollow
  attr_accessor :user_id, :question_id
  def self.find_by_id(id)
    question_follow = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL

    return nil if question_follow.empty?
    QuestionFollow.new(question_follow.first)
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
