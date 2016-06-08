.PHONY: test
test:
	pre-commit run --all-files

.PHONY: vendor
vendor:
	r10k puppetfile install
