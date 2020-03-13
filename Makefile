WORKSPACE ?= ${HOME}/.cache
ENVIRONMENT := $(notdir $(realpath $(CURDIR)))

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
	puppet generate types --environment ${ENVIRONMENT} --force || (\
		echo '\e[1;31mPlease run' && \
		echo 'mkdir -p ~/.puppetlabs/etc/puppet/ && cp /etc/skel/.puppetlabs/etc/puppet/puppet.conf ~/.puppetlabs/etc/puppet/\e[0m' && \
		false )

.PHONY: all_diffs
all_diffs:
	./bin/octocatalog-diff
