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

def getCurrentRound():
  """Get current round number
  
  Return 0 if no matches has been played.
  """
  conn = connect()
  cur = conn.cursor()
  cur.execute("SELECT MAX(round) FROM matches")
  rows = cur.fetchall()
  conn.close()
  roundNumber = rows[0][0]
  if roundNumber == None:
    roundNumber = 0
  return roundNumber

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
  roundNumber = getCurrentRound()
  conn = connect()
  cur = conn.cursor()
  if roundNumber == 0:
    cur.execute("SELECT id, name, wins, matches FROM players ORDER BY wins DESC, omw DESC")
  else:
    cur.execute("SELECT id, name, wins, matches FROM players ORDER BY wins DESC, omw DESC")
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
  cur.execute("UPDATE players SET wins = wins + 1, matches = matches + 1 WHERE id = (%s)", (winner,))
  cur.execute("UPDATE players SET loses = loses + 1, matches = matches + 1 WHERE id = (%s)", (loser,))
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
  conn = connect()
  cur = conn.cursor()
  cur.execute("SELECT MAX(round) FROM matches")
  rows = cur.fetchall()
  roundNumber = rows[0][0]
  if roundNumber == None:
    roundNumber = 1
  numberofPlayers = countPlayers()
  number_of_
  print(round_number)
  conn.close()
  















def registerMatch(id1, id2, status, roundNumber):
  conn = connect()
  cur = conn.cursor()
  cur.execute("INSERT INTO matches (player1, player2, status, round) VALUES (%s, %s, %s, %s)", (id1, id2, status, roundNumber))
  conn.commit()
  conn.close()

def registerPlayer2(name, wins, omw):
  """Adds a player to the tournament database.

  The database assigns a unique serial id number for the player.  (This
  should be handled by your SQL database schema, not in your Python code.)

  Args:
    name: the player's full name (need not be unique).
  """
  conn = connect()
  cur = conn.cursor()
  cur.execute("INSERT INTO players (name, wins, omw) VALUES (%s, %s, %s)", (name, wins, omw))
  conn.commit()
  conn.close()

def printMatches():
  """Print out the list of all matches (for testing)"""
  conn = connect()
  cur = conn.cursor()
  cur.execute("SELECT * FROM Matches")
  rows = cur.fetchall()
  print(rows)
  conn.close()

def printPlayers():
  """Print out the list of registered players (for testing)"""
  conn = connect()
  cur = conn.cursor()
  cur.execute("SELECT * FROM players")
  rows = cur.fetchall()
  print(rows)
  conn.close()

