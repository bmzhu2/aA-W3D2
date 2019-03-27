require 'sqlite3'
require 'singleton'

class RepliesDatabase < SQLite3::Database
  include Singleton
  def initialize
    super('replies.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Reply
  attr_accessor :id, :body, :subject_question_id, :parent_reply_id, :user_id


  def self.all
    data = RepliesDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_id(id)
    reply = RepliesDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
      SQL
    return nil unless reply.length > 0
    Reply.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    reply = RepliesDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
      SQL
    return nil unless reply.length > 0
    Reply.new(reply.first)
  end

  def self.find_by_question_id(subject_question_id)
    replies = RepliesDatabase.instance.execute(<<-SQL, subject_question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        subject_question_id = ?
      SQL
    return nil unless replies.length > 0
    replies.map { |row| Reply.new(row) }
  end

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @subject_question_id = options['subject_question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
  end

  def author
    user_id
  end

  def question
    subject_question_id
  end

  def parent_reply
    parent_reply_id
  end

  def child_replies
    children = RepliesDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ?
      SQL
    return nil unless children.length > 0 
    children.map {|child| Reply.new(child)}  #expecting at least one child reply, but no more than one level deep (no grandchildren)
  end

end


