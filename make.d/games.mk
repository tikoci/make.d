## ** GAMES **
# > old BSD game collections, play-games provides "arcade" TUI

.PHONY: tools-games
tools-games:
	$(call apk_add_testing, bsd-games bsd-games-doc nbsdgames nbsdgames-doc words-en)

.PHONY: play-games
play-games: /usr/bin/nbsdgames
	nbsdgames

.PHONY: play-snake
play-snake: /usr/bin/snake
	snake

.PHONY: play-mines
play-mines: /usr/bin/mines
	mines

.PHONY: play-atc
play-atc: /usr/bin/atc
	atc

.PRECIOUS: /usr/bin/nbsdgames
/usr/bin/nbsdgames:
	$(call apk_add_testing, bsd-games bsd-games-doc nbsdgames nbsdgames-doc)

.PRECIOUS: /usr/bin/snake
/usr/bin/snake:
	$(call apk_add_testing, bsd-games bsd-games-doc nbsdgames nbsdgames-doc)

.PRECIOUS: /usr/bin/mines
/usr/bin/mines:
	$(call apk_add_testing, bsd-games bsd-games-doc nbsdgames nbsdgames-doc)

.PRECIOUS: /usr/bin/atc
/usr/bin/atc:
	$(call apk_add_testing, bsd-games bsd-games-doc nbsdgames nbsdgames-doc)
