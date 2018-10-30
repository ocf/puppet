#!/usr/bin/env python3
import sys
import os
import re

LAUNCHER_SETTINGS_PATH = os.path.expanduser('~/.config/xfce4/panel/launcher-21/switch.desktop')
UPDATE_FLAGS_SCRIPT_PATH = os.path.expanduser('/opt/stats/update-flags.sh')

def changePanelState(file_path, icon_name, visibility):    
    with open(file_path, 'r') as f:
        content = f.read()
    content_1 = re.sub(r'((?<=Icon=).*)', icon_name, content)
    content_2 = re.sub(r'((?<=Name=).*)', 'Currently ' + visibility, content_1)
    content_new = re.sub(r'((?<=Visibility=).*)', visibility, content_2)
    with open(file_path, 'w') as f:
        f.write(content_new)

def main(argv=None):
    if 'Visibility=Visible' in open(LAUNCHER_SETTINGS_PATH).read():
        changePanelState(LAUNCHER_SETTINGS_PATH, 'user-invisible', 'Invisible')
        os.system(UPDATE_FLAGS_SCRIPT_PATH + " invisible")
    else:
        changePanelState(LAUNCHER_SETTINGS_PATH, 'user-available', 'Visible')
        os.system(UPDATE_FLAGS_SCRIPT_PATH + " visible")

if __name__ == '__main__':
    sys.exit(main())
