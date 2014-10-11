#!/usr/bin/env python3
import concurrent.futures
import os
import subprocess
import sys

MAX_WORKERS = 20

def local_modules(puppet):
    """Returns absolute paths to local modules."""
    modules = os.path.join(puppet, 'modules')
    return [os.path.join(modules, module) for module in os.listdir(modules)
            if not os.path.exists(os.path.join(modules, module, '.git'))]

def get_files(path, ext):
    """Returns list of absolute paths in the directory with extension."""
    if not os.path.isdir(path):
        return []
    return [os.path.join(path, file) for file in os.listdir(path)
                if file.endswith(ext)]

def validate_files(fn_files, fn_validate):
    """Runs validation on every file from each module we care about.

    Runs fn_files on each local module to get a list of files to validate, then
    validates them using fn_validate. Both steps are performed in parallel."""
    with concurrent.futures.ProcessPoolExecutor(max_workers=MAX_WORKERS) as executor:
        files = sum(executor.map(fn_files, local_modules(puppet)), [])
        results = executor.map(fn_validate, files)
        return all(results)

def get_manifests(path):
    return get_files(os.path.join(path, 'manifests'), '.pp')

def get_templates(path):
    return get_files(os.path.join(path, 'templates'), '.erb')

def validate_manifest(path):
    return subprocess.call(['puppet', 'parser', 'validate', '--', path]) == 0

def validate_template(path):
    try:
        ps = subprocess.Popen(['erb', '-x', '-P', '-T', '-', '--', path],
                stdout=subprocess.PIPE)
        output = subprocess.check_output(['ruby', '-c'],
                stdin=ps.stdout, stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as ex:
        print("Error validating template `{}`:".format(path))
        print(ex.output.decode('utf8'))
        return False
    return True

def lint_module(path):
    disabled_checks = ['80chars', 'documentation', 'puppet_url_without_modules']
    return subprocess.call(
            ['puppet-lint', '--fail-on-warnings', '--with-filename'] +
            ['--no-' + check + '-check' for check in disabled_checks] +
            ['--', path]) == 0

def list_id(x):
    return [x]

if __name__ == '__main__':
    start = os.path.realpath(__file__)
    puppet =  os.path.dirname(os.path.dirname(start))

    checks = {
        'parse_manifests':
            lambda: validate_files(get_manifests, validate_manifest),
        'validate_templates':
            lambda: validate_files(get_templates, validate_template),
        'lint_modules':
            lambda: validate_files(list_id, lint_module)
    }

    for name, fn in checks.items():
        if not fn():
            print("Check `{}` failed with errors.".format(name))
            sys.exit(1)
