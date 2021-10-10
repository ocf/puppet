Utilities for faster mirroring of Fedora
========================================

A full rsync of fedora-buffet0 can take hours just to receive the file list,
due to the fact that there are over 11 million files.  This has to happen for
every client, every time they want to update, which is murderous on the
download servers and worse on the backend NFS server.  It also slows the
propagation of important updates because mirrors simply can't poll often.

By generating a simple database of file and directory timestamps and sizes, it
becomes easy for the client to determine which files have changed since the
last mirror run and only mirror those files.  This also provides enough
information to handle files which have been deleted on the server and files
which are missing on the client.  In most situations, it also allows hardlinks
to be copied as hardlinks instead of being downloaded multiple times.

Client
======

The client is ``quick-fedora-mirror``.  It is written in zsh and uses features
which aren't really portable to bash.  It needs no external tools besides
``rsync``, ``awk``, and the usual core utilities.

A config file is required (unless you edit the script); see the sample file in
``quick-fedora-mirror.conf.dist``.  The destination directory and location of
the file to store the last mirror time must be set, though you probably want to
set the list of modules to mirror as well.

The client downloads the master file list for each module, generates lists of
new and updated files, plus those with changed sizes or checksums and passes
one combined list to rsync via --files-from.  Because all modules are copied
together, hardlinks between modules will be copied as hardlinks.  Files and
directories which no longer exist on the server are deleted after the copy has
completed, similar to the ``--delete-delay`` option to ``rsync``.

The speed improvements can be extraordinary.  Just the "receiving file list"
phase of a mirror of ``fedora-buffet`` can take over ten hours and places a
huge load on the host from which you're downloading.  With this script it takes
six seconds.

The client preserves file timestamps, but does not preserve directory
timestamps in all situations.

After a successful mirror run, the client can optionally perform a
mirrormanager checkin for each changed module.  This eliminates the need to run
report_mirror, and also avoids another full filesystem traversal.

Note that the client will currently only function which a mirror that has a
``fedora-buffet`` rsync module which contains all of the other modules within
it.  This is the case for the Fedora master mirrors as well as many of the
complete mirrors, but some sites which only mirror parts of the tree do not
have this module.


Installation
------------

Copy ``quick-fedora-mirror`` somewhere.  Copy ``quick-fedora-mirror.conf.dist``
to ``quick-fedora-mirror.conf``, edit as appropriate and copy to one of the
following:

* /etc

* ~/.config

* The directory where quick-fedora-mirror lives

* The current directory when quick-fedora-mirror runs

* Anywhere you like, if you specify the path on the command line.

You should ensure that the location you configure as ``DESTD`` exists.  the
rest of the directory structure will be created there as necessary.


Options
-------

-a  Always check the file list, and always check in all modules.  This disables
    the optimization in which the file list isn't processed at all if it hasn't
    changed from the local copy.  Useful if you believe that some files have
    gone missing from your repository and you want to force them to be fetched,
    or if you want to force a checkin.

-c  Configuration file to use.

-d  Set output verbosity.  See the VERBOSE setting in the sample configuration
    file for details.

-n  Dry run.  Don't transfer or delete any content or update the timestamp.
    Note: the master is still contacted to download the file lists.

-N  Partial dry run.  Ask rsync to do a normal transfer, but don't delete any
    local files which are not present in the file list.

-t  Instead of the previous run time, use this many seconds since the epoch.
    Implies ``-a``.

-T  Instead of the previous run time, use this.  The value is passed to ``date
    -d``, so it should be in a format which date recognizes.  ``yesterday`` and
    ``last week`` are useful examples.  Remember to quote if there are spaces.
    Implies ``-a``.

--dir-times     Resynchronize the timestamps on all directories in the
    repository.


Initial Run
-----------

The last mirror time is assumed to be the epoch if ``quick-fedora-mirror`` has
not previously been run.  This means that every single file will be checked,
which will take many hours.  If you already have a relatively recent mirror,
you can just fudge the last mirror date::

    quick-fedora-mirror -T 'last week'

Then your run will only examine (but not necessarily transfer) files which have
changed in the last week.  This may still be a lot of files, but not all of
them.  The time needn't be precise; ``quick-fedora-mirror`` will clean up stale
files and transfer missing or modified files regardless of the timestamp.

Adding a module
---------------

If you have to add a module after the fact (i.e. you already have
fedora-enchilada and you want to add fedora-alt), note that rsync will not pick
up any hardlinks.  You can of course do the download and then run the
hardlinker afterwards (see below), or do a full transfer (i.e. using ``-t 0``, though this
will most likely be far slower.

The Hardlinker
==============

A program to keep your repository fully hardlinked is included.

See the `Hardlinker documentation
<https://docs.pagure.org/quick-fedora-mirror/quick-fedora-hardlink.rst>`_ for
more information.

Server
======

The server must include one file per module to be mirrored (by default named
"fullfiletimelist-" with the module name appended).  This file is created by
running ``create-filelist``.  This will generate a list of all files in the
specified directory in the proper format and write it to the specified file.
It is generally best to write this to a temporary location and only move it
into place if the contents actually changed.  In order to avoid additional
needless filesystem traversals, it will also optionally generate two extra file
lists not used by the client:

* A simple list of files, one per line, as Fedora also maintains such a file.
* A file specifically listing specific types of image files, which is useful for other
  Fedora tools not related to mirroring.

The main file list contains a timestamp and size for each file.  The timestamp
in the file list is the newer of mtime and ctime.  This means that newly
created hardlinks will cause both the original and the new version of the file
to appear to have been updated.  ``rsync`` will note that the extra files are
up to date and will create the hardlinks directory (assuming, of course, that
it is called with ``-H``).  But this works *only* if all of the file lists are
updated at once.

The output also includes a section with checksums of selected files.  By
default, this includes only the repomd.xml files, because they are important,
their names never change and neither does their size.  So if they ever get
missed by the mirror process somehow, it's still possible to detect this
situation.

The format of the file list is simple enough to be parsed by a shell script
with a few calls to awk.

Options
-------

``create-filelist`` takes the following options:

-d  The directory to scan.

-t  The filename of the full file list with times.  Defaults to stdout.

-f  The filename of the list of files with no additional data.  If not
    specified, no plain file list is generated.

-c  Include checksums of all repomd.xml files.

-C  Include checksums of all of the specified filenames wherever they appear in
    the repository.  May be specified multiple times.

-s  Don't include any fullfiletimelist files in the file list with times to
    avoid inception.

-S  Don't include the named file in the file list with times.  May be specified
    multiple times.

Integration
-----------

An example of how you might call ``create-filelist`` as part of a larger system
to manage several modules is given in the ``example-create-filelist-wrapper``.
This is only an example, and will at least need to be edited as appropriate for
your environment.

Downstream Mirrors
==================

Note that this method works for downstream mirrors as well.  Intermediate
mirrors should *not* modify the filelists.

Assuming ``rsync`` is called with --delay-updates, downstream mirrors should
always have a consistent view of the repository.  Due to deletes happening
after rsync runs, downstreams may briefly see a few extra files but if using
the file lists this shouldn't matter.  Changes should get out very quickly,
because mirrors can poll frequently without overloading servers.

Non-Fedora Usage
================

Note that you can of course run the server component in your own repository,
but the clients will of course need to specify ``REMOTE``, ``MASTERMODULE`` and
the ``MODULES`` array to map module names to directories.  The client also
makes the assumption that all of the separate module are all subdirectories
accessible from within a master module.  If you would like to use this code but
those constraints don't fit your use case, please file an issue and I'll be
happy to take a look.

Be sure to run ``create-filelist`` after every repository change.  If you
hardlink files between one module and another, you must update the file lists
in both modules.  You can also run it from cron, but clients may see the
repository in an inconsistent state in the interval between the changes and the
file list generation.  This will not result in any persistent errors on your
clients, though; they will pick up the correct repository state on the next
run.

It's a good idea to run a diff or something and only copy the output into place
if the new output differs.  The example wrapper shows one way to do this.

FAQ
===

* Why, when I look at the debugging output, does rsync complain about all of
  these duplicate directories?

  Any directories with updated timestamps will be added to the transfer lists.
  rsync will implicitly add all levels of parent directories of any updated
  files, and then complain when that results in duplicates.  This is completely
  harmless.

* Does ``quick-fedora-mirror`` preserve all timestamps?

  It will preserve timestamps on files, but if you modify a timestamp locally
  to be newer than what the master has, then that timestamp won't be modified
  unless the file changes on the master.

  Timestamps on directories are, in general, not preserved.  This script must
  do any file deletion after the main rsync process has completed, which will
  necessarily alter various directories and their timestamps.

  Code to make a third rsync call to fix up timestamps is being worked on, but
  this won't be made the default.


Authorship and License
======================

All of this code was originally written by Jason Tibbitts <tibbs@math.uh.edu>
and has been donated to the public domain.  If you require a statement of
license, please consider this work to be licensed as "CC0 Universal", any
version you choose.
