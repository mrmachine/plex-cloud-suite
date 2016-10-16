#!/usr/bin/env python

# Move files and directories from local storage to ACD storage.

import os
import shutil

for root, dirs, files in os.walk('/mnt/local-storage', topdown=False):
    relpath = os.path.relpath(root, '/mnt/local-storage')
    # print 'relpath: %s' % relpath

    # Skip downloads.
    if relpath.split(os.sep)[0] == 'Downloads':
        # print 'skip downloads'
        continue

    # Create missing directories.
    dstpath = os.path.join('/mnt/acd-storage', relpath)
    if not os.path.exists(dstpath):
        # print 'makedirs: %s' % dstpath
        os.makedirs(dstpath)

    # Move files.
    for file in files:
        print 'move %s -> %s' % (
            os.path.join(root, file),
            os.path.join(dstpath, file),
        )
        shutil.move(os.path.join(root, file), os.path.join(dstpath, file))

    # Remove empty directory.
    if relpath != '.':
        # print 'rmdir: %s' % root
        os.rmdir(root)
