# Working Directory

* [Installation](#installation)
* [Usage](#usage)
* [Schemes](#schemes)
* [Similar Projects](#similar-projects)
* [Change Log](#changelog)
* [License](#license)

---

Working Directory (`wd`) is a simple set of aliases and shell functions
providing numbered storage of commonly-used directories, quick retrieval of
stored directories, and support for multiple schemes to allow easy context
switching when working with multiple projects.

It's compatible with bash and zsh—please open an issue if you'd like support for
your favorite shell.

## INSTALLATION

The easiest way to install wd is by running its install script:

    ./install.sh

This will put the necessary files in `$HOME/.wd` (except the man page, see
below.) If you want it somewhere else, just put the files in the `wd` directory
of the package wherever you want. Then add the following lines to your `.bashrc`
file (or appropriate equivalent thereof):

    export WDHOME="${HOME}/.wd"
    source "${WDHOME}/wd.sh"
    # OR, for ZSH:
    # source "${WDHOME}/wd.zsh"
    shopt -s direxpand # optional, for bash $WD[0-9] env. var. expansion

Note that a man page is included but not installed due to platform
inconsistency. Please copy the file (`wd.1.gz`) to your man page directory. For
Linux that's usually `/usr/share/man/man1`.

## USAGE

There are 10 slots: 0 through 9. Slot 0 is the default, implied slot. The first
time you open your shell after installing wd, a scheme named "default" is
created and selected which is empty. As you navigate around normally, you can
save your current directory to slots with `wds` and list contents of each slot
with `wdl`, and change directory to a slot with `wd`.

Here's all the commands:

|Command |Description
|------- |-----------
| `wd`   |Jump to the directory stored in the default slot 0
| `wds`  |Store the current working directory in the default slot (slot 0)
| `wd1`  |Jump to the directory in slot 1
| `wds3` |Store the current directory in slot 3
| `wdl`  |Display all slot contents
| `wdc`  |Clear all slots (prints cleared scheme first!)
| `wdscheme` |Print the name of the current scheme

Note that the numbers are just shown as examples, any slot between 0 and 9 could
be used, e.g. `wd9`.

Slot contents will persist across and between shell sessions because the current
scheme is stored in a file in your $WDHOME directory.

It's possible to clear a single slot by setting it to a period (`.`), e.g.:

    wds3 .

The result is slot 3 becoming "empty", as if it'd never been set.

A set of environment variables, one for each slot—`$WD0`, `$WD1`,
etc.—are created and updated as you modify the slots. Note that these
may be out-of-sync when you change schemes from a different shell. If this
happens, running `wdscheme` will print the current scheme and also update
these environment variables.

## SCHEMES

Schemes help you separate sets of directories you commonly use for each task or
project you work on in your shell. To change schemes, run:

    wdscheme myscheme

...where `myscheme` is some name for your scheme. If the scheme file already
exists, wd will clone your current slots to the new scheme file and switch to
it.

When a new name is given, the file `{name}.scheme` is created in `$WDHOME` and
the new scheme's name is recorded as the current scheme in
`$WDHOME/current_scheme`.

If you want to change the scheme within the context of your current shell only,
you can use the `-t` option instead:

    wdscheme -t tempscheme

This updates your environment with an override variable (WDSCHEME) but will not
change the current scheme stored in the filesystem, so other shells will be
unaffected and can continue using the previous scheme slots.

## SIMILAR PROJECTS

While Working Directory is unique in its schemes and quick aliases, there are
plenty more directory management and bookmarking tools out there:

* [CDargs](http://www.skamphausen.de/cgi-bin/ska/CDargs)
* [apparix](https://github.com/micans/apparix)
* [autojump](https://github.com/wting/autojump#name)

If you're a user of shells besides bash or zsh: you can try the pure-shell
version in `main`, but if it doesn't work for you, try the legacy version written
in sh and perl,
[wd-1.12.](https://github.com/karlin/working-directory/tree/master)

## CHANGELOG

Working Directory is developed by Karlin Fox, with help and advice from David Crosby and Wayne Seguin.

See [CHANGELOG.md](CHANGELOG.md) for a full history.

## TESTING

If you want to hack on wd, you can clone the repo's `main` (default) branch and
run `git submodule init && git submodule update` to fetch `bats`. Before you can
run the tests, you need to comment-out or remove the interactive shell check on
line 7 of `wd/wd.sh`! If all the tests fail then you may have forgotten that
step. Also sorry zsh folks, bats only supports bash.

You can run the tests with:

    ./test/bats/bin/bats test/wd.bats

## LICENSE

Working Directory is licensed under the BSD Zero Clause license, included in
[LICENSE.](LICENSE)