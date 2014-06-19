default: build

build:
	coffee -o lib/ src/
	
venv:
	virtualenv venv
	. venv/bin/activate && pip install -r requirements/docs.txt

docs: venv
	. venv/bin/activate && $(MAKE) -C docs html

.PHONY: docs
