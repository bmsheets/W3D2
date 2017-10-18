require_relative 'question_database'
require_relative 'model_base'

class QuestionFollow < ModelBase
  attr_accessor :user_id, :question_id

  def self.get_table
    "question_follows"
  end

  def self.followers_for_question_id(question_id)
    question_follow = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN question_follows ON users.id = question_follows.user_id
      WHERE
        question_follows.question_id = ?
    SQL

    question_follow.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    question_follow = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN question_follows ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL

    question_follow.map { |user| Question.new(user) }
  end

  def self.most_followed_questions(n)
    question_follow = QuestionDatabase.instance.execute(<<-SQL, n)
      SELECT
        *
      FROM
        question_follows
      JOIN questions ON question_follows.question_id = questions.id
      GROUP BY
        question_follows.question_id
      ORDER BY
        COUNT(question_follows.question_id) DESC
      LIMIT
        ?
    SQL

    question_follow.map { |hash| Question.new(hash) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
