DROP TABLE users;
DROP TABLE questions;
DROP TABLE question_follows;
DROP TABLE replies;
DROP TABLE question_likes;
PRAGMA foreign_keys = ON;


CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255),
  lname VARCHAR(255)
);

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255),
  body TEXT,
  associated_author_id INTEGER,
  FOREIGN KEY (associated_author_id) REFERENCES users(id)
);

CREATE TABLE question_follows (
  question_id INTEGER,
  user_id INTEGER,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT,
  subject_question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (subject_question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE question_likes (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Andrew', 'Chan'), 
  ('Brian', 'Zhu'),
  ('Karen', 'Lai');

INSERT INTO 
  questions (title, body, associated_author_id)
VALUES 
  ('SQL', 'I need help with SQL', (SELECT id FROM users WHERE fname = 'Brian' AND lname = 'Zhu' )), 
  ('I need help', 'How do shot web', (SELECT id FROM users WHERE fname = 'Andrew' AND lname = 'Chan'));

INSERT INTO 
  question_follows (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'SQL'),
  (SELECT id FROM users WHERE fname = 'Brian' AND lname = 'Zhu' ));

INSERT INTO 
  replies (body, subject_question_id, parent_reply_id, user_id)
VALUES
  ('Forgot join what''s next? Shit outta luck, okay!', (SELECT id FROM questions WHERE title = 'SQL'), NULL, 
  (SELECT id FROM users WHERE fname = 'Brian' AND lname = 'Zhu' )),
  ('It seems that way oof', (SELECT id FROM questions WHERE title = 'SQL'), 1, 
  (SELECT id FROM users WHERE fname = 'Brian' AND lname = 'Zhu' )),
  ('Stop replying to yourself', (SELECT id FROM questions WHERE title = 'SQL'), 2, 
  (SELECT id FROM users WHERE fname = 'Brian' AND lname = 'Zhu' ));


INSERT INTO 
  question_likes (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'SQL'), 
  (SELECT id FROM users WHERE fname = 'Karen' AND lname = 'Lai'));