.POSIX:
NAME = steamer
DESK = $(NAME).desktop
PREFIX = ${HOME}/.local
BIN_LOC = $(DESTDIR)$(PREFIX)/bin
DESK_LOC = $(DESTDIR)$(PREFIX)/share/applications
.PHONY: install install-desktop install-all uninstall all

all: $(NAME) $(DESK)

$(NAME):
	cp steamer.sh $(NAME)

$(DESK):
	sed "s|@placeholder@|$(NAME)|" steamer.desktop.in > $(DESK)

install: $(NAME)
	chmod 755 $(NAME)
	mkdir -p $(BIN_LOC)
	cp -vf $(NAME) $(BIN_LOC)/

install-desktop:
	mkdir -p $(DESK_LOC)
	cp $(DESK) $(DESK_LOC)/

install-all: install install-desktop

uninstall:
	rm -vf $(BIN_LOC)/$(NAME)
	rm -vf $(DESK_LOC)/$(DESK)

clean:
	rm -vf $(NAME) $(DESK)

