require 'sqlite3'
require 'singleton'
require_relative 'question_follows.rb'

class UsersDatabase < SQLite3::Database
  include Singleton
  def initialize
    super('users.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end
  
class User
  attr_accessor :id, :fname, :lname

  def self.all
    data = UsersDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    user = UsersDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
      SQL
    return nil unless user.length > 0

    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = UsersDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
      SQL
    return nil unless user.length > 0

    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    Question.find_by_author_id(id)
  end

  def authored_replies
    Reply.find_by_user_id(id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(id)
  end

  def liked_questions
  end

  def average_karma
  end
end