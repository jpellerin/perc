PERC = perc
VPATH = $(PATH)

all: test build check

build:
	$(PERC) build

test: $(PERC)
	$(PERC) test

cover:
	$(PERC) test -C

check:
	$(PERC) check


$(PERC):
	npm install -g git://github.com/jpellerin/perc

.PHONY: all build check test cover
