## ** GAMES **
# > old BSD game collections, play-games provides "arcade" TUI

.PHONY: all-games
all-games: 
	$(call apk_add_testing, bsd-games bsd-games-doc nbsdgames nbsdgames-doc)

.PHONY: play-games
/usr/bin/nbsdgames:
	$(call apk_add_testing, bsd-games bsd-games-doc nbsdgames nbsdgames-doc)
play-games: /usr/bin/nbsdgames
	nbsdgames

.PHONY: play-snake
/usr/bin/snake:
	$(call apk_add_testing, bsd-games bsd-games-doc nbsdgames nbsdgames-doc)
play-snake: /usr/bin/snake
	snake

.PHONY: play-mines
/usr/bin/mines:
	$(call apk_add_testing, bsd-games bsd-games-doc nbsdgames nbsdgames-doc)
play-mines: /usr/bin/mines
	mines

.PHONY: play-atc
/usr/bin/atc: 
	$(call apk_add_testing, bsd-games bsd-games-doc nbsdgames nbsdgames-doc)
play-atc: /usr/bin/atc
	atc	
