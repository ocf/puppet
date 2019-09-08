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

.PHONY: octocatalog-diff-uncached
$(WORKSPACE)/.octocatalog-diff-cache:
octocatalog-diff-uncached:
	octocatalog-diff \
		--bootstrap-then-exit \
		--bootstrapped-from-dir=$(WORKSPACE)/.octocatalog-diff-cache

# Run octocatalog-diff for a particular hostname
# Add a --debug flag to get much more verbose output
diff_%: $(WORKSPACE)/.octocatalog-diff-cache
	octocatalog-diff \
		-n $*.ocf.berkeley.edu \
		--bootstrapped-to-dir=$(WORKSPACE)/.octocatalog-diff-cache \
		--enc-override environment=production,parameters::use_private_share=false \
		--ignore 'Ini_setting[puppet.conf/master/storeconfigs]' \
		--ignore 'Ini_setting[puppet.conf/master/storeconfigs_backend]' \
		--ignore 'Ini_setting[puppetdbserver_urls]' \
		--ignore 'Ini_setting[soft_write_failure]' \
		--ignore 'File[/tmp/*/routes.yaml]' \
		--display-detail-add

# Run octocatalog-diff across all nodes that can be fetched from puppetdb
# TODO: Make this faster by just selecting a single node from each class we
# care about (not selecting all desktops/hozers for example)
#all_diffs: $(WORKSPACE)/.octocatalog-diff-cache
all_diffs: octocatalog-diff-uncached
	curl -s --tlsv1 \
		--cacert /etc/ocfweb/puppet-certs/puppet-ca.pem \
		--cert /etc/ocfweb/puppet-certs/puppet-cert.pem \
		--key /etc/ocfweb/puppet-certs/puppet-private.pem \
		https://puppetdb:8081/pdb/query/v4/nodes \
	| jq -r '.[] | .certname' \
	| cut -d '.' -f 1 \
	| sort \
	| xargs -n 1 -P $(shell grep -c ^processor /proc/cpuinfo) -I @ $(MAKE) -s diff_@
