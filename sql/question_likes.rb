require 'sqlite3'
require 'singleton'

class QuestionLikesDatabase < SQLite3::Database
  include Singleton
  def initialize
    super('question_likes.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class QuestionLike
  attr_accessor :question_id, :user_id

  def self.all
    data = QuestionLikesDatabase.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| QuestionLike.new(datum) }
  end

  def self.likers_for_question_id(question_id)
    likers = QuestionLikesDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.id, users.fname, users.lname
      FROM
        question_likes
      JOIN
        users ON users.id = question_likes.user_id
      WHERE
        question_likes.question_id = ?
    SQL
    return nil unless likers.length > 0
    likers.map {|liker| User.new(liker)}
  end

  def self.num_likes_for_question_id(question_id)
    num_likes = QuestionLikesDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(user_id)
      FROM
        question_likes
      WHERE
        question_likes.question_id = ?
    SQL
  end

  def self.liked_questions_for_user_id(user_id)
    liked_questions = QuestionLikesDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.id, questions.title, questions.body, questions.associated_author_id
      FROM
        question_likes
      WHERE question_likes.question_id IN
        (SELECT
          question_likes.question_id
        FROM
          question_likes
        WHERE
          user_id = ?)
      JOIN 
          questions ON questions.id = question_likes.question_id
    SQL
    return nil unless liked_questions.length > 0
    liked_questions.map {|question| Question.new(question)}
  end

  def self.most_liked_questions(n)
  end

  def initialize(options)
    @question_id = options['question_id']
    @user_id = options['user_id']
  end
end
