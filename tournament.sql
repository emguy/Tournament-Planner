-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

-- We first drop all views and tables.
DROP VIEW IF EXISTS player_pairing;
DROP VIEW IF EXISTS player_status;
DROP VIEW IF EXISTS player_omw;
DROP VIEW IF EXISTS player_wins;
DROP VIEW IF EXISTS player_matches;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS players;

--- TABLE players (two columns) ---
--
--  Maps the id to the full name of each players. see the example below
-- 
--  id |   name
------------------------
--   1 | Tom Hanks
--   2 | Bruce Brown
--   3 | Bill Gates
--   4 | George Bush
--   5 | James Bond
--   6 | Tim Hotton
--   7 | Dustin Hoffman
--   8 | Steve Barton
--
CREATE TABLE players(id serial PRIMARY KEY, name VARCHAR(255) NOT NULL);

--- TABLE matches (four columns) ---
--
--  Describes the participants (player id) and the outcome of each match that 
--  has been played, see the example below
--
--  Here, the outcome is 1 if player_1 is the winner, 2 if player_2 is the 
--  winner, 3 if draw.
-- 
--  id |  player_1 | player_2 | outcome
------------------------------------------
--   1 |     1     |    2     |    1
--   2 |     3     |    4     |    1
--   3 |     5     |    6     |    2
--   4 |     7     |    8     |    2
--   5 |     1     |    3     |    1
--   6 |     5     |    7     |    1
--   7 |     2     |    4     |    2
--   8 |     6     |    8     |    2
--
CREATE TABLE matches(id serial PRIMARY KEY,
                     player_1 INTEGER REFERENCES players (id),  
                     player_2 INTEGER REFERENCES players (id),  
                     outcome INTEGER DEFAULT 0
                    );

--- VIEW player_matches (four columns) ---
--
--  It lists all matches played by each player including the outcome and his
--  opponent. Here the outcome is 1 if the player (player_id) wins this 
--  match (match_id).
-- 
--  This view is dependend on the table matches and the table players.
--
--  player_id |  match_id | opponent | outcome
---------------------------------------------
--     1      |     1     |    2     |    1
--     2      |     1     |    1     |    0
--     3      |     2     |    4     |    1
--     4      |     2     |    3     |    0
--     5      |     3     |    6     |    0
--     6      |     3     |    5     |    1
--     7      |     4     |    8     |    0
--     8      |     4     |    7     |    1
--     1      |     5     |    3     |    1
--     2      |     5     |    1     |    0
--     3      |     6     |    7     |    1
--     4      |     6     |    5     |    0
--     5      |     7     |    4     |    0
--     6      |     7     |    2     |    1
--     7      |     8     |    8     |    0
--     8      |     8     |    6     |    1
--
CREATE VIEW player_matches AS
  SELECT players.id AS player_id, matches.id AS match_id,
  CASE WHEN (matches.player_1 = players.id) 
       THEN matches.player_2
       ELSE matches.player_1
  END
  AS opponent,
  CAST (
    CASE WHEN (matches.player_1 = players.id AND matches.outcome = 1) 
      OR (matches.player_2 = players.id AND matches.outcome = 2)
      THEN 1
      ELSE 0 
      END AS INTEGER
  ) AS outcome
  FROM players JOIN matches 
  ON matches.player_1 = players.id OR matches.player_2 = players.id; 

--- VIEW player_wins (three columns) ---
--
--  List the number played matches and the number of wins for each player.
--     
--  This view is dependend on the view player_matches and the table players.
--
--  player_id | matches | wins 
--------------------------------
--     1      |     2   |   2
--     2      |     2   |   0
--     3      |     2   |   1
--     4      |     2   |   1
--     5      |     2   |   1
--     6      |     2   |   1
--     7      |     2   |   0
--     8      |     2   |   2
--
CREATE VIEW player_wins AS
  SELECT players.id AS player_id, COALESCE(tmp.matches, 0) AS matches, 
  COALESCE(tmp.wins, 0) AS wins 
  FROM players LEFT JOIN 
  (SELECT player_id, CAST(count(*) AS INTEGER) AS matches, 
  CAST(sum(outcome) AS INTEGER) AS wins
  FROM player_matches GROUP BY player_id) AS tmp
  ON players.id = tmp.player_id;

--- VIEW player_omw (three columns) ---
--
--  List the omw for each players
-- 
--  This view is dependend on the view player_wins, the view player_matches, and the table players.
--
--  player_id | omw
---------------------
--     1      |  1
--     3      |  1
--     4      |  0
--     5      |  0
--     6      |  1
--     8      |  1
--     2      |  0 
--     7      |  0
--
CREATE VIEW player_omw AS
  SELECT players.id AS player_id, COALESCE(tmp.omw, 0) AS omw 
  FROM players LEFT JOIN 
  (SELECT player_matches.player_id, CAST(sum(wins) AS INTEGER) AS omw 
  FROM player_matches JOIN player_wins
  ON player_wins.player_id = player_matches.opponent and outcome = 1 
  GROUP BY player_matches.player_id) AS tmp
  ON players.id = tmp.player_id;

--- VIEW player_status (five columns) ---
--
--  Summaries the status of each players. It includes the number of matches
--  played so far, the number of his winning matches, his omw, and his standing.

--  This view is dependend on the view player_wins, the view player_omw, and the table players.
-- 
--  player_id | matches | wins | omw | rank
---------------------------------------------
--     1      |    2    |  2   |  1  |  1    
--     8      |    2    |  2   |  1  |  2    
--     3      |    2    |  1   |  1  |  3    
--     6      |    2    |  1   |  1  |  4    
--     4      |    2    |  1   |  0  |  5    
--     5      |    2    |  1   |  0  |  6    
--     7      |    2    |  2   |  0  |  7    
--     2      |    2    |  2   |  0  |  8    
--
CREATE VIEW player_status AS
  SELECT player_wins.player_id, matches, wins, omw, 
  ROW_NUMBER() OVER(ORDER BY wins DESC, omw DESC) AS rank
  FROM player_wins LEFT JOIN player_omw 
  ON player_wins.player_id = player_omw.player_id;

--- VIEW player_pairing (two columns) ---
--
--  Generate the pairing from the player standing.
--
--  This view is dependend on the view player_status.
-- 
--  player_1 | player_2
------------------------------
--     1     |    8  
--     3     |    6     
--     4     |    5     
--     7     |    2     

CREATE VIEW player_pairing AS
  SELECT first.player_id AS player_1, second.player_id AS player_2 FROM
  (SELECT rank, player_id FROM player_status WHERE rank % 2 = 1) AS first
  JOIN
  (SELECT rank, player_id FROM player_status WHERE rank % 2 = 0) AS second
  ON first.rank = second.rank - 1;

---- FOR TESTING --
--INSERT INTO players (name) VALUES('Tom Hanks');
--INSERT INTO players (name) VALUES('Bruce Brown');
--INSERT INTO players (name) VALUES('Bill Gates');
--INSERT INTO players (name) VALUES('George Bush');
--INSERT INTO players (name) VALUES('James Bond');
--INSERT INTO players (name) VALUES('Tim Hotton');
--INSERT INTO players (name) VALUES('Dustin Hoffman');
--INSERT INTO players (name) VALUES('Steve Barton');
--INSERT INTO matches (player_1, player_2, outcome) VALUES(1, 2, 1);
--INSERT INTO matches (player_1, player_2, outcome) VALUES(3, 4, 1);
--INSERT INTO matches (player_1, player_2, outcome) VALUES(5, 6, 2);
--INSERT INTO matches (player_1, player_2, outcome) VALUES(7, 8, 2);
--INSERT INTO matches (player_1, player_2, outcome) VALUES(1, 3, 1);
--INSERT INTO matches (player_1, player_2, outcome) VALUES(5, 7, 1);
--INSERT INTO matches (player_1, player_2, outcome) VALUES(2, 4, 2);
--INSERT INTO matches (player_1, player_2, outcome) VALUES(6, 8, 2);
--SELECT * FROM players;
--SELECT * FROM matches;
--SELECT * FROM player_matches;
--SELECT * FROM player_wins;
--SELECT * FROM player_omw;
--SELECT * FROM player_status;
--SELECT * FROM player_pairing;
---- TESTING THE PAIRING --
--SELECT player_pairing.player_1 AS id1, first.name, 
--       player_pairing.player_2 AS id2, second.name FROM 
--       (player_pairing JOIN players AS first ON player_1 = first.id)
--       JOIN players AS second ON player_2 = second.id;
--

