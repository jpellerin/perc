PATH := $(PATH):node_modules/.bin
VPATH = $(PATH)

PERC = perc
TEST = $(PERC) test
COVER = $(PERC) cover

JSLIB = lib
VENDORJS = $(shell find vendor/ -type f -name *.js)
JSCOVER = .lib-cov
JSTESTS = spec

COFFEE = coffee
COFFEECOVER = coffeecover
COFFEE_FLAGS =

all: $(PERC)
	$(PERC) build

static/app.js static/vendor.js: all $(JSLIB)/*.js $(VENDORJS)

$(JSLIB)/%.js: $(PERC) $(JSLIB)/%.coffee
	$(PERC) compile -c $<

$(JSCOVER)/%.js: $(PERC) $(JSLIB)/%.coffee
	$(PERC) compile --coverage -c $<

test: $(PERC) $(JSLIB)/*.js
	$(TEST) $(JSTESTS)

jstest: test

cover: $(JSCOVER)/*.js
	$(PERC) cover

$(COFFEE) $(COFFEECOVER) $(PERC):
	npm install

.PHONY: all test jstest cover
