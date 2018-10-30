#!/usr/bin/env python3
import sys
import os
from ocflib.account.utils import is_staff
from ocflib.misc.whoami import current_user

LAUNCHER_SETTINGS_PATH = os.path.expanduser('~/.config/xfce4/panel/launcher-21/switch.desktop')

def main(argv=None):
    #Removes the visibility toggle button from the panel if the user is not staff
    notstaff = not is_staff(current_user())
    if notstaff:
        os.remove(LAUNCHER_SETTINGS_PATH)

if __name__ == '__main__':
    sys.exit(main())
