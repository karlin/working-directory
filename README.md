# Working Directory

* Developed by Karlin Fox
* With help and advice from David Crosby and Wayne Seguin

Working Directory (`wd`) is a simple set of aliases and shell functions
providing named storage of directories, as well as quick retrieval of
previously-stored directories. It has support for multiple schemes of working
directories.

Compatible with bash and zsh. Please open an issue if you'd like support for
your favorite shell!

## INSTALLATION

The easiest way to install (except the man page, see below) is this script:

    ./install.sh

This will put the necessary files in `$HOME/.wd`. If you want it somewhere
else, just put the files in the `wd` directory of the package wherever you
want. Then add the following lines to your `.bashrc` file (or appropriate
equivalent thereof):

    export WDHOME="${HOME}/.wd"
    source "${WDHOME}/wd.sh"
    # OR, for ZSH:
    # source "${WDHOME}/wd.zsh"
    shopt -s direxpand # optional, for bash $WD[0-9] env. var. expansion

Note that a man page is included but not installed due to platform
inconsistency. Please copy the file (`wd.1.gz`) to your man page
directory. For Linux, usually `/usr/share/man/man1`.

## USAGE

There are 10 slots: 0 through 9. Slot 0 is the default, implied slot.
`wdl` lists the contents of the current scheme's slots.

Some examples:

|Command |Description
|------- |-----------
| `wdl`  |Display all slot contents
| `wds`  |Store the current working directory in the default slot (slot 0)
| `wds1` |Store the current working directory in slot 1
| `wd`   |Jump to the default directory (slot 0)
| `wd1`  |Jump to the directory in slot 1
| `wdc`  |Clear all slots

Slot contents will persist between shell sessions because the current scheme is
stored in $WDHOME.

It's possible to clear only a single slot with `.`, e.g.

    wds3 .

will result in slot 3 having its contents cleared.

A set of environment variables named after the slots (`$WD0`, `$WD1`,
etc.) are created and updated as you modify the slots. Note that these
may be out-of-sync when you change schemes from a different shell. If this
happens, running `wdscheme` will print the current scheme and also update
these environment variables.

## SCHEMES

Schemes can help you separate sets of directories commonly used for each task
you work on on the command line. To change schemes, simply say:

    wdscheme myscheme

...where `myscheme` is some name for your scheme. If the scheme file already
exists, wd will clone your current slots to the new scheme file and switch to
it.

If the name is new, a new `{name}.scheme` file is created in `$WDHOME` and the
new scheme's name is recorded in the `$WDHOME/current_scheme` file.

If you want to change the scheme within the context of your current shell only,
use the `-t` option instead:

    wdscheme -t tempscheme

This will update your environment with an override variable (WDSCHEME) and
will not overwrite the current scheme on disk, meaning other shells will be
unaffected.

## SIMILAR PROJECTS

Working Directory is unique in its schemes and quick aliases, but there are
more generic directory management and bookmarking tools out there:

* [CDargs](http://www.skamphausen.de/cgi-bin/ska/CDargs)
* [apparix](https://github.com/micans/apparix)
* [autojump](https://github.com/wting/autojump#name)

Attention users of shells besides bash or zsh!: you can try the pure-shell version but if it doesn't work for you, try the legacy version written in sh and perl,
[wd-1.12.](https://github.com/karlin/working-directory/tree/master)

## CHANGELOG

See [CHANGELOG.md](CHANGELOG.md).

## LICENSE

Working Directory is licensed under the BSD Zero Clause license, included
in [LICENSE.](LICENSE)