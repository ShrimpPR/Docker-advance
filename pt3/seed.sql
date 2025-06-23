DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    favorite_insult VARCHAR(255) NOT NULL
);

INSERT INTO users (name, favorite_insult) VALUES
    ('Alice', 'You absolute muppet'),
    ('Bob', 'You daft sod'),
    ('Charlie', 'You utter plank'),
    ('Diana', 'You cheeky git'),
    ('Eve', 'You numpty');