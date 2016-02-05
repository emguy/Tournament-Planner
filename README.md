# Tournament Planner
This program keeps track of players and matches in a game tournament (Swiss
system) through the use of a PostgreSQL database.

## Summary
This program includes the following:

1. A database schema for storing data required to generate paired matches in a tournament using the Swiss System.
2. A python module for connecting to database, register/delete/count players, report/delete matches, rank players and create a new Swiss parings.
3. A testing code is also provided for debuging the program and for testing the database.

## Features
1. The program supports draw games.
2. The program utilizes Opponents Match Win (OMW) scheme to determine the standing and the pairing.

## Requirements
1. Python 2.7
2. PostgreSQL

## Database setup
1. Enter the PostgreSQL interactive terminal by typing the following on a Linux shell

        $ psql

2. Create a database with name 'tournament' by excuting the following command within the PostgreSQL terminal

        => CREATE DATABASE tournament;

3. Connect to the database 'tournament', by excuting 

        => \connect tournament


5. Excute the sql queries from the file 'tournament.sql' by excuting

        => \i tournament.sql

6. To test the APIs of this program, excuting the following on a Linux shell

        $ python tournament.py

## API Usages

#### def connect():
Connect to the PostgreSQL database.  Returns a database connection.

#### deleteMatches():
Remove all the match records from the database.

#### def deletePlayers():
Remove all the player records from the database.

#### def countPlayers():
Returns the number of players currently registered.

#### def registerPlayer(name):
Adds a player to the tournament database.

The database assigns a unique serial id number for the player.  (This
should be handled by your SQL database schema, not in your Python code.)

Args:
  name: the player's full name (need not be unique).

#### def playerStandings():
Returns a list of the players and their win records, sorted by wins.

The first entry in the list should be the player in first place, or a player
tied for first place if there is currently a tie.

Returns:
  A list of tuples, each of which contains (id, name, wins, matches):
    id: the player's unique id (assigned by the database)
    name: the player's full name (as registered)
    wins: the number of matches the player has won
    matches: the number of matches the player has played

#### def reportMatch(winner, loser):
Records the outcome of a single match between two players.

  Args:
    winner:  the id number of the player who won
    loser:  the id number of the player who lost

#### def swissPairings():
Returns a list of pairs of players for the next round of a match.

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

Bugs report to Yu Zhang (emguy2000@gmail.com).
