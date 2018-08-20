#!/usr/bin/env python3
'''
Script that adds users in the 'ocfhpc' LDAP group to SLURM as a SLURM user.
'''
import subprocess

from ocflib.account.utils import list_group


DEFAULT_ACCOUNT = 'users'


def main():
    ocfhpc_ldap_user_set = set(list_group('ocfhpc'))

    # This produces a newline-separated list of SLURM users.
    ocfhpc_slurm_user_list = subprocess.run(
        ['sacctmgr', '-noP', 'list', 'users', 'format=User'],
        stdout=subprocess.PIPE,
        check=True
    ).stdout.decode().split('\n')[:-1]
    ocfhpc_slurm_user_set = set(ocfhpc_slurm_user_list)

    users_to_be_added = ocfhpc_ldap_user_set.difference(ocfhpc_slurm_user_set)

    if not users_to_be_added:
        return

    for new_user in users_to_be_added:
        # Add a new user to SLURM and commit changes immediately.
        subprocess.run(['sacctmgr', '-i', 'add', 'user', new_user, 'account={}'.format(DEFAULT_ACCOUNT)])


if __name__ == '__main__':
    main()
