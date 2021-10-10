The Hardlinker
==============

While ``quick-fedora-mirror`` is able to copy hardlinks that exist on the main
repository as hardlinks, this only happens when the hardlinking exists in the
upstream repository at the time your mirror is done and if you are polling
often you may miss some.  So in order to save space, it is still a good idea to
occasionally ensure that your local repository is fully hardlinked.

It is perfectly fine to run the existing hardlink tool to do this.  Howerver,
the included ``quick-fedora-hardlink`` program can make use of the file lists
and properties of software repositories to find hardlinking opportunities
without requiring a complete filesystem traversal.  This can often save a
significant amount of time.



The hardlinker is written in python, though a zsh version with less
functionality is also in the repository.

Invocation
----------

``quick-fedora-hardlink`` requires no options.  It will attempt to locate your
existing quick-fedora-mirror.conf file and proceed to process the file lists.

The intent is that all relevant options can be parsed from the configuration
file and also specified directly on the command line, but this is not yet
implemented.

Options
-------
  -h, --help            show this help message and exit
  -c CONFIG, --config CONFIG
                        Path to the configuration file.
  --debug               Enable debugging.
  -n, --dry-run         Just print what would be done without linking
                        anything.
  --no-ctime            Do not skip files which have different ctimes in the
                        file lists.
  -q, --quiet           Print nothing to standard output except the end-of-run
                        summary.
  -s, --silent          Print nothing at all to standard output.
  -v, --verbose         Print the source and dest of each hardlink created.
  -t, --tier1           For tier 1 mirrors, also consider pre-bitflip content.

Normally the configuration file is found using the same method that
``quick-fedora-mirror`` uses.  If necessary, the config file location can be
specified with ``-c``.

When ``-n`` or ``--dry-run`` are passed, nothing will be hardlinked but all
other operations will be carried out normally.

Tier 1 mirrors (which can access protected content on their upstream mirrors)
should pass ``-t`` or ``--tier1`` so that the protected content will be
processed as well.  Retrieving this information from the configuration file is
not yet implimented.

If ``--no-ctime`` is passed, ``quick-fedora-hardlink`` will not use the
modification time from the file list in deciding whether or not files chould be
processed for equality.  If the content on the master mirrors is fully
hardlinked and the file lists are up to date, the hardlinked files will all
have exactly the same ctime entries in the file lists.  Using this knowledge
permits a significant optimization, but if the server content isn't fully
hardlinked then some opportunities will be missed.

The ``--no-ctime`` option is most useful when run on the master mirrors to
ensure that the master content is fully hardlinked.  It is not generally useful
on downstream mirrors when the master mirrors are kept fully hardlinked.

The ``-q``/``--quiet`` and ``-s``/``--silent`` options can be used to suppress
output.  The default output includes a progress display and an end-of-run
summary.  ``-q``/``--quiet`` will show only the summary.  ``-s``/``--silent``
will suppress all non-error output.

Similarly, ``-v``/``--verbose`` and ``--debug`` will output additional
information.  For a large repository, ``--debug`` may output an exceptional
volume of information.


Authorship and License
======================

All of this code was originally written by Jason Tibbitts <tibbs@math.uh.edu>
and has been donated to the public domain.  If you require a statement of
license, please consider this work to be licensed as "CC0 Universal", any
version you choose.
