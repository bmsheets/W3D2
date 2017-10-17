require_relative 'question_databse'

class Reply
  attr_accessor :question_id, :reply_id, :user_id, :body

  def self.find_by_id(id)
    reply = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL

    return nil if reply.empty?
    Reply.new(reply.first)
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @reply_id = options['reply_id']
    @user_id = options['user_id']
    @body = options['body']
  end
end
