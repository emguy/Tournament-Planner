-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

DROP VIEW IF EXISTS player_status;
DROP VIEW IF EXISTS player_omw;
DROP VIEW IF EXISTS player_wins;
DROP VIEW IF EXISTS player_matches;
DROP TABLE IF EXISTS matches;
DROP TABLE IF EXISTS players;

CREATE TABLE players(id serial PRIMARY KEY, 
                     name VARCHAR(255) NOT NULL
                    );

CREATE TABLE matches(id serial PRIMARY KEY,
                     player1 INTEGER REFERENCES players (id),  
                     player2 INTEGER REFERENCES players (id),  
                     status INTEGER DEFAULT 0,
                     round INTEGER DEFAULT 1
                    );

CREATE VIEW player_matches AS
  SELECT players.id AS player_id, matches.id AS match_id,
  CASE WHEN (matches.player1 = players.id) 
       THEN matches.player2
       ELSE matches.player1
  END
  AS opponent,
  CAST (
      CASE WHEN (matches.player1 = players.id AND status = 1) 
                 OR
                (matches.player2 = players.id AND status = 2)
           THEN 1
           ELSE 0 
      END
    AS INTEGER) AS outcome
  FROM players JOIN matches ON matches.player1 = players.id OR matches.player2 = players.id; 

CREATE VIEW player_wins AS
  SELECT player_id, count(*) AS matches, sum(outcome) AS wins
  FROM player_matches GROUP BY player_id ORDER BY player_id;

CREATE VIEW player_omw AS
  SELECT players.id AS player_id, COALESCE(tmp.omw, 0) AS omw FROM players LEFT JOIN 
    (SELECT player_matches.player_id, sum(wins) AS omw FROM player_matches JOIN
    player_wins
    ON player_wins.player_id = player_matches.opponent and outcome = 1 
    GROUP BY player_matches.player_id) AS tmp
  ON players.id = tmp.player_id;

CREATE VIEW player_status AS
  SELECT player_wins.player_id, matches, wins, omw 
  FROM player_wins LEFT JOIN player_omw on player_wins.player_id = player_omw.player_id;

-- for testing --
-- INSERT INTO players (name) VALUES('Tom Hanks');
-- INSERT INTO players (name) VALUES('Bruce Brown');
-- INSERT INTO players (name) VALUES('Bill Gates');
-- INSERT INTO players (name) VALUES('George Bush');
-- INSERT INTO players (name) VALUES('James Bond');
-- INSERT INTO players (name) VALUES('Tim Hotton');
-- INSERT INTO players (name) VALUES('Justin Hoffman');
-- INSERT INTO players (name) VALUES('Steve Barton');
-- INSERT INTO matches (player1, player2, status, round) VALUES(1, 2, 1, 1);
-- INSERT INTO matches (player1, player2, status, round) VALUES(3, 4, 1, 1);
-- INSERT INTO matches (player1, player2, status, round) VALUES(5, 6, 2, 1);
-- INSERT INTO matches (player1, player2, status, round) VALUES(7, 8, 2, 1);
-- INSERT INTO matches (player1, player2, status, round) VALUES(1, 3, 1, 2);
-- INSERT INTO matches (player1, player2, status, round) VALUES(5, 7, 1, 2);
-- INSERT INTO matches (player1, player2, status, round) VALUES(2, 4, 2, 2);
-- INSERT INTO matches (player1, player2, status, round) VALUES(6, 8, 2, 2);
-- SELECT * FROM player_wins;
-- SELECT * FROM player_omw;
-- SELECT * FROM player_status;
