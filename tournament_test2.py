#!/usr/bin/env python
#
# Test cases for tournament.py
# These tests are not exhaustive, but they should cover the majority of cases.
#
# If you do add any of the extra credit options, be sure to add/modify these test cases
# as appropriate to account for your module's added functionality.

from tournament import *

deletePlayers()
deleteMatches()

registerPlayer("Bruce Hanks")
registerPlayer("Tom Cruise")
registerPlayer("Tim Hotton")
registerPlayer("James Bond")

printPlayers()
print("-------------")

registerMatch(1, 2, 1, 1)
registerMatch(3, 4, 1, 1)
registerMatch(1, 3, 1, 2)
registerMatch(2, 4, 1, 2)

printMatches()
print("-------------")
playerStandings()
print("-------------")

#swissPairings()


#printPlayers()
#print("-------------")
#playerStandings()
#print("-------------")
#reportMatch(2, 1)
#print("-------------")
#printPlayers()
#print("-------------")
playerStandings()
#print("-------------")

#registerPlayer2("George Bush", 8 , 6)
#registerPlayer2("Tim Hotton", 8 , 3)
#registerPlayer2("Bill Gates", 2 , 2)
#registerPlayer2("Tom Hanks", 9 , 5)

