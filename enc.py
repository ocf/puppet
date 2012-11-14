#!/usr/bin/env python
"""Puppet ENC that classifies nodes based on YAML documents in a single file.

ARGUMENTS

    The only argument is the node's Puppet certname (FQDN).

INPUT

    Multiple YAML documents are separated by '---' in a single input file.
    Each YAML document corresponds to a single node and contains the
    following key(s). Only hostname is required.

      - hostname:    identifies the node based on the Puppet certname
      - classes:     list of classes to include
      - environment: string representing the node's environment

    All other keys are exposed to Puppet as parameters (see output below).
    They will also be exposed to Hiera (useful for dynamic data sources).

OUTPUT

    The YAML hash of Puppet resources contains the following keys.

        - classes:       list of classes to include, defaults to []
        - parameters:    mapping of top scope variables exposed during
                         catalog compilation,
                         defaults to {subnet: esh, type: server}
        - environment:   string representing the node's environment,
                         defaults to 'production'

"""

import sys
import yaml

def get_hostname(fqdn):
    """Extract hostname and domain from FQDN"""
    hostname = fqdn.split('.')[0]
    if hostname:
        return hostname
    else:
        raise ValueError("Could not find hostname in FQDN: " + fqdn)

def load_yaml(filename):
    """Load the YAML input file containing multiple documents"""
    try:
        with open(filename) as f:
            input = list(yaml.safe_load_all(f))
    except IOError:
        raise IOError("Could not load YAML input file: " + filename)
    except yaml.scanner.ScannerError:
        raise ValueError("Failed to parse YAML input file: " + filename)
    if input:
        return input
    else:
        raise ValueError("YAML input file appears to be empty: " + filename)

def load_node(certname):
    """Load the YAML document corresponding to a node"""
    hostname = get_hostname(certname)
    input = load_yaml('/opt/puppet/env/production/hieradata/enc.yaml')
    for document in input:
        if document['hostname'] == hostname:
            node = document
            break
    try:
        if node:
            return node
        else:
            raise ValueError("YAML node definition is empty.")
    except NameError:
        raise KeyError("Node hostname not found: " + hostname)

def print_yaml(node):
    """Output node definition as YAML hash of Puppet resources"""
    resources = ( {
                'classes': [],
                'parameters': {'subnet': 'esh', 'type': 'server'},
                'environment': 'production',
                } )
    for attribute in node:
        if attribute in ("classes", "environment"):
            resources[attribute] = node[attribute]
        else:
            resources['parameters'][attribute] = node[attribute]
    yaml_opts = ( {
                'explicit_start':     True,
                'default_flow_style': False,
                } )
    yaml.safe_dump(resources, sys.stdout, **yaml_opts)
    return resources

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        raise ValueError("Usage: enc.py CERTNAME")
    else:
        node = load_node(sys.argv[1])
        print_yaml(node)

if __name__ == "__main__":
    main()
