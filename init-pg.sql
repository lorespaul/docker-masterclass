CREATE TABLE IF NOT EXISTS users(
  id serial PRIMARY KEY,
  email character varying(50) NOT NULL,
  username character varying(50) NOT NULL
);

INSERT INTO users(email, username) VALUES
('test1@gmail.com', 'test1'),
('test2@gmail.com', 'test2');
