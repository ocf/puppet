WORKSPACE ?= ${HOME}/.cache

.PHONY: all
all: vendor install-hooks

.PHONY: venv
venv: bin/venv-update Makefile
	bin/venv-update \
		venv= $@ -ppython3 \
		install= 'pre-commit>=1.0.0'

.PHONY: test
test: venv install-hooks
	venv/bin/pre-commit run --all-files

.PHONY: install-hooks
install-hooks: venv
	venv/bin/pre-commit install -f --install-hooks

vendor: Puppetfile
	r10k puppetfile install --verbose --color

.PHONY: all_diffs
all_diffs:
	./bin/octocatalog-diff
