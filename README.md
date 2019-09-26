# Working Directory

* Developed by Karlin Fox
* With help and advice from David Crosby and Wayne Seguin

Compatible with bash or zsh. Please open an issue if you'd like support for your favorite shell!

Working Directory (`wd`) is a simple set of aliases and shell functions that
provides named storage of directories, as well as quick retrieval of
previously-stored directories. It has support for multiple schemes of working
directories.

## INSTALLATION

The easiest way to install (except the man page, see below) is this script:

    $ ./install.sh

This will put the necessary files in `$HOME/.wd`. If you want it somewhere
else, just put the files in the `wd` directory of the package wherever you
want. Then add the following lines to your `.bashrc` file (or appropriate
equivalent thereof):

    export WDHOME=$HOME/.wd
    source ~/.wd/wd.sh

Note that there is a man page included. This file is not installed because
of platform inconsitency. Please copy this file (wd.1.gz) to your man page
directory. For linux, that is usually /usr/share/man/man1 or similar.

				
## USAGE

There are 10 slots: 0 through 9.  Slot 0 is the default, implied slot.
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
	
Slot contents will persist from session to session.

It's possible to clear only a single slot with `.`,

    $ wds3 .

will result in slot 3 having its contents cleared.
	
A set of environment variables named after the slots (`$WD0`, `$WD1`,
etc.) are created and updated as you modify the slots.

## SCHEMES

Schemes can help you separate sets of directories commonly used for each task
you work on on the command line. To change schemes, simply say:

    $ wdscheme myscheme

...where `myscheme` is some label for your scheme. If the scheme file already
exists, wd will clone your current slots to the new scheme file and switch to
it.
	
If the label is new, a new `.scheme` file is created in `$WDHOME` and the new
scheme's name is recorded in the `$WDHOME/current_scheme` file.

## SIMILAR PROJECTS

Working Directory is unique in its schemes and quick aliases, but there are
more generic directory management and bookmarking tools out there:

* [CDargs](http://www.skamphausen.de/cgi-bin/ska/CDargs)
* [apparix](http://micans.org/apparix)
* [autojump](https://github.com/joelthelion/autojump/wiki)

Attention users of other shells! You can still use wd but you'll have to use the [legacy version written in sh and perl, wd-1.12](https://github.com/karlin/working-directory/tree/master)

## LICENSE

Working Directory is licensed under the GPL, included in [LICENSE.](https://github.com/karlin/working-directory/blob/master/LICENSE)

    Working Directory is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Working Directory is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Working Direcory; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
