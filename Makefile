.PHONY: all
all: vendor

.PHONY: test
test:
	pre-commit run --all-files

vendor: Puppetfile
	r10k puppetfile install
