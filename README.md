# Tournament-Planner
This program keeps track of players and matches in a game tournament (Swiss
system) through the PostgreSQL database.

## Requirements
1. Python 2.7
2. PostgreSQL

## Usage
1. Enter the PostgreSQL interactive terminal by typing the following on a Linux shell
        $ psql
2. Create a database with name 'tournament' by excuting the following command within the PostgreSQL terminal
        => CREATE DATABASE tournament;
3. Connect to the database 'tournament', by excuting 
        => \connect tournament
4. Connect to the database 'tournament', by excuting 
        => \connect tournament
5. Excute the sql queries from the file 'tournament.sql' by excuting
        => \i tournament.sql
6. To test the APIs of this program, excuting the following on a Linux shell
        $ python tournament.py

    
