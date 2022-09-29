#!/usr/bin/env python3
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Dict
from typing import Optional


# Based on github/octocatalog-diff:examples/script-overrides/git-extract-submodules/git-extract.sh
# (b2834b58bfd0c2f22797daccff53bcdf8cda915b)

# This script is called from lib/octocatalog-diff/catalog-util/git.rb and is used to
# archive and extract a certain branch of a git repository into a target directory.


def eprint(*args, **kwargs):
    print(*args, **kwargs, file=sys.stderr)


def get_worktree_status(cwd: Optional[Path] = None) -> Dict[Path, Dict[str, str]]:
    process = subprocess.run(
        ('git', 'worktree', 'list', '--porcelain'),
        check=True,
        stdout=subprocess.PIPE,
        cwd=cwd,
    )
    stdout = process.stdout.decode()
    ret: Dict[Path, Dict[str, str]] = dict()
    current_entry = None
    for line in stdout.splitlines():
        if line == '':
            if current_entry is not None:
                current_tree, current_dict = current_entry
                ret[current_tree] = current_dict
            current_entry = None
            continue
        (attr, *rest) = line.split(' ', maxsplit=1)
        data = rest[0] if rest else ''
        if attr == 'worktree':
            assert current_entry is None
            current_entry = (Path(data), dict())
        else:
            assert current_entry is not None
            current_tree, current_dict = current_entry
            current_dict[attr] = data
    return ret


def get_commit_hash(ref: str, repo: Optional[Path] = None) -> str:
    return subprocess.run(
        ('git', 'rev-parse', ref),
        check=True,
        stdout=subprocess.PIPE,
        cwd=repo,
    ).stdout.decode().strip()


if __name__ == '__main__':
    EXTRACT_BRANCH = os.environ['OCD_GIT_EXTRACT_BRANCH']
    EXTRACT_TARGET = os.environ['OCD_GIT_EXTRACT_TARGET']

    target_dir = Path(EXTRACT_TARGET).resolve()
    target_sha = get_commit_hash(EXTRACT_BRANCH)

    subprocess.run(
        ('git', 'worktree', 'prune'),
        check=True,
    )

    worktree_status = get_worktree_status()
    needs_update = False  # do submodules need updating?
    if target_dir not in worktree_status:
        # worktree doesn't exist
        needs_update = True
        eprint('adding worktree')
        if target_dir.exists():
            shutil.rmtree(target_dir)
        subprocess.run(
            ('git', 'worktree', 'add', str(target_dir), target_sha),
            check=True,
        )
    elif worktree_status[target_dir]['HEAD'] != target_sha:
        # worktree exists, but is the wrong commit
        needs_update = True
        eprint('updating worktree (checkout)')
        subprocess.run(
            ('git', 'checkout', target_sha),
            check=True,
            cwd=target_dir
        )
    if needs_update:
        eprint('updating submodules')
        subprocess.run(
            ('git', 'submodule', 'sync', '--recursive'),
            check=True,
            cwd=target_dir,
        )
        subprocess.run(
            ('git', 'submodule', 'update', '--init', '--recursive'),
            check=True,
            cwd=target_dir,
        )
