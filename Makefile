.PHONY: all
all: vendor

.PHONY: venv
venv: bin/venv-update Makefile
	bin/venv-update \
		venv= $@ -ppython3 \
		install= 'pre-commit>=0.15.0'

.PHONY: test
test: venv install-hooks
	venv/bin/pre-commit run --all-files

.PHONY: install-hooks
install-hooks: venv
	venv/bin/pre-commit install -f --install-hooks

vendor: Puppetfile
	r10k puppetfile install
