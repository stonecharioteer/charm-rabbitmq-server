#!/usr/bin/make
PYTHON := /usr/bin/env python
CHARM_DIR := $(PWD)
HOOKS_DIR := $(PWD)/hooks
TEST_PREFIX := PYTHONPATH=$(HOOKS_DIR)

clean:
	rm -f .coverage
	find . -name '*.pyc' -delete
	rm -rf .venv
	(which dh_clean && dh_clean) || true

.venv:
	sudo apt-get install -y gcc python-dev python-virtualenv python-apt
	virtualenv .venv --system-site-packages
	.venv/bin/pip install -I -r test-requirements.txt

lint:
	@flake8 --exclude hooks/charmhelpers hooks unit_tests
	@charm proof

bin/charm_helpers_sync.py:
	@mkdir -p bin
	@bzr cat lp:charm-helpers/tools/charm_helpers_sync/charm_helpers_sync.py \
        > bin/charm_helpers_sync.py

sync: bin/charm_helpers_sync.py
	@$(PYTHON) bin/charm_helpers_sync.py -c charm-helpers.yaml

publish: lint
	bzr push lp:charms/rabbitmq-server
	bzr push lp:charms/trusty/rabbitmq-server

unit_test: clean .venv
	@echo Starting tests...
	env CHARM_DIR=$(CHARM_DIR) $(TEST_PREFIX) .venv/bin/nosetests unit_tests/

functional_test:
	@echo Starting amulet tests...
	@juju test -v -p AMULET_HTTP_PROXY --timeout 900
