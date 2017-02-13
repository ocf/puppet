.PHONY: all
all: vendor

.PHONY: venv
venv: bin/venv-update Makefile
	bin/venv-update \
		venv= $@ -ppython3 \
		install= ckuehl-pre-commit-types==0.7.6.dev1

.PHONY: test
test: venv install-hooks
	venv/bin/pre-commit run --all-files

.PHONY: install-hooks
install-hooks: venv
	venv/bin/pre-commit install -f --install-hooks

vendor: Puppetfile
	r10k puppetfile install
