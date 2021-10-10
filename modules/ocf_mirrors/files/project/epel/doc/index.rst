Utilities for Mirroring Fedora Faster
=====================================

``quick-fedora-mirror`` comprises a suite of programs which together can be
used to propagate changes through a network of repository mirrors more quickly
than using rsync alone.

Background
----------

A full rsync of fedora-buffet0 (the main rsync repository which contains all
mirrorable Fedora content) can take hours just to receive the file list, due to
the fact that there are over 12 million files at the time this is written.  The
file list generation has to happen for every client, every time they want to
update, which is murderous on the download servers and worse on the backend NFS
server.  It also slows the propagation of important updates because mirrors
simply can't poll often.

With the addition of a simple database of file and directory timestamps and
sizes, it becomes relatively easy for a downstream mirror to determine which
files have changed since the last run and pass those to rsync without asking
the server to stat 12 million files.  The client must still do a filesystem
traversal and some processing, but only in the event that the file list has
changed, and only of the modules which have actually changed.

In addition, Fedora requests that its mirrors run a tool to report back to the
master server with information on what content they have.
``quick-fedora-mirror`` encapsulates this so that there is no need to configure
and run that additional tool.

Components
----------

The complete ``quick-fedora-mirror`` suite has a server side (which generates
the file lists) and a client side (which processes those file lists).  There is
also a utility to hardlink a repository.

See the individual pages for documentation on each component:

* `The file list generator <create-filelist.rst>`_
* `The client <quick-fedora-mirror.rst>`_
* `The hardlinker <quick-fedora-hardlink.rst>`_

Client Installation
-------------------



Non-Fedora Usage
----------------


FAQ
---


Authorship and License
----------------------

All of this code was originally written by Jason Tibbitts <tibbs@math.uh.edu>
and has been donated to the public domain.  If you require a statement of
license, please consider this work to be licensed as "CC0 Universal", any
version you choose.

