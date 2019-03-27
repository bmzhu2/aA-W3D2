require 'sqlite3'
require 'singleton'
require_relative 'users_database.rb'
require_relative 'questions_database.rb'

class QuestionFollowsDatabase < SQLite3::Database
  include Singleton
  def initialize
    super('question_follows.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class QuestionFollow
  attr_accessor :question_id, :user_id

  def self.all
    data = QuestionFollowsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionFollowsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        question_follows
      JOIN 
        users ON users.id = question_follows.user_id
      WHERE 
        question_follows.question_id = ? 
      SQL
      return nil unless followers.length > 0
      followers.map { |follower| User.new(follower) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionFollowsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.associated_author_id
      FROM
        question_follows
      JOIN 
        questions ON questions.id = question_follows.question_id
      WHERE 
        question_follows.user_id = ? 
      SQL
      return nil unless questions.length > 0
      questions.map { |question| Question.new(question) }    
  end

  def self.most_followed_questions(n)
    most_followed = QuestionFollowsDatabase.instance.execute(<<-SQL, n)
    
    SELECT
      questions.id, questions.title, questions.body, questions.associated_author_id
    FROM
      question_follows
    WHERE
      question_follows.user_id IN (
      SELECT
        user_id
      FROM
        question_follows
      GROUP BY
        question_id
      HAVING
        COUNT(question_follows.user_id)
      ORDER BY
        followers DESC
      LIMIT
        ?
      )
    JOIN
        questions ON questions.id = question_follows.question_id
    SQL
    return nil unless most_followed.length > 0
    most_followed.map { |question| Question.new(question) }
  end

  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  

end
