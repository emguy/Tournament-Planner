#!/usr/bin/env python
# 
# tournament.py -- implementation of a Swiss-system tournament
#

import psycopg2

def connect():
  """Connect to the PostgreSQL database.  Returns a database connection."""
  return psycopg2.connect("dbname=tournament")

def deleteMatches():
  """Remove all the match records from the database."""
  conn = connect()
  cur = conn.cursor()
  cur.execute("DELETE FROM matches")
  conn.commit()
  conn.close()

def deletePlayers():
  """Remove all the player records from the database."""
  conn = connect()
  cur = conn.cursor()
  cur.execute("DELETE FROM matches")
  cur.execute("DELETE FROM players")
  conn.commit()
  conn.close()

def countPlayers():
  """Returns the number of players currently registered."""
  conn = connect()
  cur = conn.cursor()
  cur.execute("SELECT count(id) AS num FROM players")
  rows = cur.fetchall()
  conn.close()
  return rows[0][0]

def registerPlayer(name):
  """Adds a player to the tournament database.

  The database assigns a unique serial id number for the player.  (This
  should be handled by your SQL database schema, not in your Python code.)

  Args:
    name: the player's full name (need not be unique).
  """
  conn = connect()
  cur = conn.cursor()
  cur.execute("INSERT INTO players (name) VALUES (%s)", (name,))
  conn.commit()
  conn.close()

def playerStandings():
  """Returns a list of the players and their win records, sorted by wins.

  The first entry in the list should be the player in first place, or a player
  tied for first place if there is currently a tie.

  Returns:
    A list of tuples, each of which contains (id, name, wins, matches):
      id: the player's unique id (assigned by the database)
      name: the player's full name (as registered)
      wins: the number of matches the player has won
      matches: the number of matches the player has played
  """
  conn = connect()
  cur = conn.cursor()
  cur.execute("""SELECT players.id, players.name, wins, matches 
              FROM player_status LEFT JOIN players 
              ON players.id = player_status.player_id ORDER BY rank""")
  if cur.rowcount == 0: 
    # Here we consider the case when no match has been played among players
    cur.execute("""SELECT players.id, players.name, COALESCE(wins, 0),  
                COALESCE(matches, 0) FROM players LEFT JOIN player_status 
                ON players.id = player_status.player_id""")
  rows = cur.fetchall()
  conn.close()
  return rows

def reportMatch(winner, loser):
  """Records the outcome of a single match between two players.

  Args:
    winner:  the id number of the player who won
    loser:  the id number of the player who lost
  """
  conn = connect()
  cur = conn.cursor()
  cur.execute("""UPDATE matches SET outcome = 1 WHERE player_1 = (%s) 
              AND player_2 = (%s)""", (winner, loser))
  if (cur.rowcount == 0):
    cur.execute("""UPDATE matches SET outcome = 2 WHERE player_1 = (%s) 
                AND player_2 = (%s)""", (loser, winner))
    if (cur.rowcount == 0):
      cur.execute("""INSERT INTO matches (player_1, player_2, outcome) 
                  VALUES ((%s), (%s), 1)""", (winner, loser))
  conn.commit()
  conn.close()

def swissPairings():
  """Returns a list of pairs of players for the next round of a match.

  Assuming that there are an even number of players registered, each player
  appears exactly once in the pairings.  Each player is paired with another
  player with an equal or nearly-equal win record, that is, a player adjacent
  to him or her in the standings.

  Returns:
    A list of tuples, each of which contains (id1, name1, id2, name2)
      id1: the first player's unique id
      name1: the first player's name
      id2: the second player's unique id
      name2: the second player's name
  """
