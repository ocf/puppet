puppet
======
[![Build Status](https://jenkins.ocf.berkeley.edu/buildStatus/icon?job=puppet/master)](https://jenkins.ocf.berkeley.edu/job/puppet/)

![ocf servers](https://i.fluffy.cc/RnF1JrLNrzczC5s291tsdlLrbl1fd12S.png)

This repository contains the [Puppet][puppet] modules used to maintain and
configure the servers and desktops used by the [Open Computing Facility][ocf]
at UC Berkeley.

These modules are generally intended to be used on the latest [Debian][debian]
stable release, though probably also work on Debian-derived distros (such as
[Ubuntu][ubuntu]).

This README outlines development practices for OCF volunteer staff members. If
you're a member of the UC Berkeley community and interested in getting
involved, [check us out][about-staff]!

## Making and testing changes
### Puppet environments

Every staffer owns a _puppet environment_. A puppet environment is a copy of
this repository which you can use for testing out changes to this puppet code.

Puppet environments are stored on the puppetmaster in `/opt/puppet/env/`. Each
staffer's environment has the same name as their user name:

    ckuehl@lightning:~$ ls -l /opt/puppet/env/
    drwxr-xr-x 6 ckuehl  ocf  4.0K Nov  5 11:04 ckuehl
    drwxr-xr-x 5 daradib ocf  4.0K Aug 11 22:53 daradib
    drwxr-xr-x 5 tzhu    ocf  4.0K Sep  2 17:46 tzhu
    drwxr-xr-x 6 willh   ocf  4.0K Oct  9 13:56 willh

The puppetmaster has the service CNAME `puppet`, so you can connect to it via `ssh
puppet`.

You should make your changes in your puppet environment and test them before
pushing them to GitHub to be deployed into production.

### Setting up your puppet environment

If you're using your puppet environment for the first time, there's a little
setup you'll have to do. `cd` into your puppet environment
(`/opt/puppet/env/you`) and run:

    you@lightning:/opt/puppet/env/you$ git pull
    you@lightning:/opt/puppet/env/you$ make

This will update your puppet environment to the latest version on master and
install the appropriate third-party modules and the pre-commit hooks.

### Testing using your puppet environment

Before pushing, you should test your changes by switching at least one of the
affected servers to your puppet environment and triggering a run. Changing
environments requires root, so if you don't have root, you will need to ask a
root staffer to change the environment.

If you have root, you can change a host's environment with the `puppet-trigger`
command:

    ckuehl@supernova:~$ ssh raptors
    ckuehl@raptors:~$ sudo puppet-trigger -te ckuehl

This changes the environment to `ckuehl` and triggers a run.

Make sure to switch the environment back to `production` after pushing your
changes.

### Linting and validating the puppet config

We use [pre-commit](http://pre-commit.com/) to lint our code before commiting.
The main checks are:

* Parsing puppet manifests for syntax errors (`puppet parser validate`)
* Validating Ruby `erb` templates for syntax errors
* Linting puppet manifests to ensure a consistent style (`puppet-lint`)
* Running a bunch of standard Python linters (the same ones we use for all of
  our Python projects)

While some of the rules might seem a little arbitrary, it helps keep the style
consistent, and ensure annoying things like trailing whitespace don't creep in.

You can simply run `make install-hooks` to install the necessary git hooks;
once installed, pre-commit will run every time you commit.

Alternatively, if you'd rather not install any hooks, you can simply use `make
test` to run the hooks on every file on-demand. This is what Jenkins will do
before deploying your change.

### Deploying changes to production

GitHub is the authoritative source for this repository; at all times, the
`production` environment on the puppetmaster will be a clone of the `master`
branch on GitHub (we use [Jenkins][jenkins] to keep it up-to-date).

Pushing to GitHub will immediately update the production environment, but your
changes will not take effect until the puppet agent runs on each server (every
30 minutes, at an arbitrary offset). You can use the `puppet-trigger` script if
you want it to happen faster.

## Conventions and styling
### Naming conventions

All OCF modules that are primarily intended for OCF use (currently, all of
them) should be prefixed with `ocf_`.

For modules that apply only to a specific service (such as the MySQL server),
use the service CNAME (such as `mysql`) for the module name. Otherwise, use
common sense to come up with a reasonable name (e.g. `ocf_desktop`).

For manifests that don't refer to a service but are commonly used, such as one
that sets up LDAP/Kerberos authentication (used on every server) or the SSL
bundle generation manifest (used by lots of servers), consider just creating a
new class under the `ocf` module.

Try not to refer to servers by hostname (such as `lightning`). Instead, use the
service CNAME (such as `puppet`) or the top-level variables `$::hostname` and
`$::fqdn`.

### Including third-party modules

Third-party modules can be helpful. Try to only use ones that are actively
maintained.

We use [r10k][r10k] to include third-party modules in our config. This has
benefits over storing them in a global directory on the puppetmaster (e.g. with
the `puppet module` tool), and is easier to manage than using git submodules:

* This puppet config repository is self-contained
* Adding and updating modules can be tested in an environment before being
  inflicted on every server
* Staff members can test third-party modules without needing root on the
  puppetmaster
* Modules can be installed from [Puppet Forge][puppet-forge] without needing to
  have a git repository

### Styling

In lieu of an actual style guide, please try to make your code consistent with
the existing code (or help write a style guide?), and ensure that it passes
validation (including pre-commit).

### Minimal config file management

Try to change as few things as possible; this makes upgrading to newer versions
of packages and operating systems easier, as well as making it more obvious to
future staffers what options you actually changed.

Instead of overwriting an entire config file just to change one value, try to
[use augeas][augeas] ([example][augeas-example]) or [sed][sed]
to change just the necessary values.

## Future improvements

* Trigger puppet runs automatically after production is updated
* Better monitoring of puppet runs (e.g. to see when a server has not updated
  recently, which is a common problem on desktops)

[puppet]: https://en.wikipedia.org/wiki/Puppet_(software)
[ocf]: https://www.ocf.berkeley.edu/
[debian]: https://www.debian.org/
[ubuntu]: http://www.ubuntu.com/
[about-staff]: https://www.ocf.berkeley.edu/about/staff
[jenkins]: https://jenkins.ocf.berkeley.edu/view/puppet-deploy/
[r10k]: https://github.com/puppetlabs/r10k
[puppet-forge]: https://forge.puppet.com/
[augeas]: https://puppet.com/docs/puppet/4.8/types/augeas.html
[augeas-example]: https://github.com/ocf/puppet/blob/57c9bec/modules/ocf/manifests/auth.pp#L95
[sed]: https://github.com/ocf/puppet/blob/e7de500/modules/ocf_desktop/manifests/grub.pp#L13
