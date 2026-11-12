-- =====================================================
-- CodeQuest database script  (MySQL 8.x)
-- Run this file once:  mysql -u root -p < codequest_db.sql
-- =====================================================
CREATE DATABASE IF NOT EXISTS codequest_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE codequest_db;

-- Student accounts
CREATE TABLE IF NOT EXISTS users (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  username    VARCHAR(30)  NOT NULL,
  email       VARCHAR(100) NOT NULL,
  password    VARCHAR(64)  NOT NULL,              -- SHA-256 hash (hex)
  xp          INT          NOT NULL DEFAULT 0,
  level_no    INT          NOT NULL DEFAULT 1,
  created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_users_username UNIQUE (username),
  CONSTRAINT uq_users_email    UNIQUE (email),
  CONSTRAINT chk_users_xp      CHECK (xp >= 0),
  CONSTRAINT chk_users_level   CHECK (level_no >= 1),
  INDEX idx_users_xp (xp)
) ENGINE=InnoDB;

-- Administrator accounts
CREATE TABLE IF NOT EXISTS admins (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  username  VARCHAR(30) NOT NULL,
  password  VARCHAR(64) NOT NULL,                 -- SHA-256 hash (hex)
  CONSTRAINT uq_admins_username UNIQUE (username)
) ENGINE=InnoDB;

-- Programming questions (missions)
CREATE TABLE IF NOT EXISTS missions (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  title          VARCHAR(150) NOT NULL,
  description    TEXT         NOT NULL,
  category       ENUM('Java','SQL','DSA')          NOT NULL,
  difficulty     ENUM('Easy','Medium','Hard')      NOT NULL,
  option_a       VARCHAR(255) NOT NULL,
  option_b       VARCHAR(255) NOT NULL,
  option_c       VARCHAR(255) NOT NULL,
  option_d       VARCHAR(255) NOT NULL,
  correct_answer CHAR(1)      NOT NULL,
  xp_reward      INT          NOT NULL DEFAULT 10,
  created_by     INT          NULL,
  created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_missions_answer CHECK (correct_answer IN ('A','B','C','D')),
  CONSTRAINT chk_missions_xp     CHECK (xp_reward > 0),
  CONSTRAINT fk_missions_admin FOREIGN KEY (created_by)
      REFERENCES admins(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Student submissions (ONE attempt per student per mission)
CREATE TABLE IF NOT EXISTS mission_submissions (
  id              INT AUTO_INCREMENT PRIMARY KEY,
  user_id         INT        NOT NULL,
  mission_id      INT        NOT NULL,
  selected_answer CHAR(1)    NOT NULL,
  is_correct      TINYINT(1) NOT NULL DEFAULT 0,
  xp_awarded      INT        NOT NULL DEFAULT 0,
  submitted_at    TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_one_attempt UNIQUE (user_id, mission_id),
  CONSTRAINT fk_sub_user    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE,
  CONSTRAINT fk_sub_mission FOREIGN KEY (mission_id) REFERENCES missions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Default administrator  ->  username: admin   password: admin123
INSERT IGNORE INTO admins (id, username, password) VALUES
 (1, 'admin', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9');

-- Sample missions (you can add more from the Admin panel). Inserted only if the table is empty.
INSERT INTO missions (title, description, category, difficulty, option_a, option_b, option_c, option_d, correct_answer, xp_reward, created_by)
SELECT * FROM (
 SELECT 'Default int value' AS t, 'What is the default value of an instance variable of type int in Java?' AS d, 'Java' AS c, 'Easy' AS df, '0' AS a, 'null' AS b, '1' AS cc, 'Undefined' AS dd, 'A' AS ans, 10 AS xp, 1 AS cb
 UNION ALL SELECT 'Stop overriding', 'Which keyword prevents a method from being overridden in a subclass?', 'Java', 'Medium', 'static', 'final', 'abstract', 'private', 'B', 20, 1
 UNION ALL SELECT 'String comparison', 'What is the result of this code?\nString a = new String("hi");\nString b = "hi";\nSystem.out.println(a == b);', 'Java', 'Hard', 'true', 'false', 'Compile error', 'Runtime exception', 'B', 30, 1
 UNION ALL SELECT 'Fetch rows', 'Which SQL statement is used to retrieve data from a table?', 'SQL', 'Easy', 'GET', 'OPEN', 'SELECT', 'FETCH', 'C', 10, 1
 UNION ALL SELECT 'Filter groups', 'Which clause filters groups produced by GROUP BY?', 'SQL', 'Medium', 'WHERE', 'HAVING', 'ORDER BY', 'LIMIT', 'B', 20, 1
 UNION ALL SELECT 'Unique values', 'Which constraint prevents duplicate values in a column?', 'SQL', 'Hard', 'CHECK', 'DEFAULT', 'UNIQUE', 'FOREIGN KEY', 'C', 30, 1
 UNION ALL SELECT 'LIFO structure', 'Which data structure follows the Last-In-First-Out principle?', 'DSA', 'Easy', 'Queue', 'Stack', 'Array', 'Graph', 'B', 10, 1
 UNION ALL SELECT 'Binary search', 'What is the time complexity of binary search on a sorted array?', 'DSA', 'Medium', 'O(n)', 'O(n log n)', 'O(log n)', 'O(1)', 'C', 20, 1
 UNION ALL SELECT 'Quick sort worst case', 'What is the worst-case time complexity of Quick Sort?', 'DSA', 'Hard', 'O(n log n)', 'O(n^2)', 'O(log n)', 'O(n)', 'B', 30, 1
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM missions);
