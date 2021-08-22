### 3.0 - 2021-10-03
* add wdscheme -t to set shell-local scheme override
* refactor: dedupe and use internal functions more often
* fix: `install.sh` pointed to old README
* improve `install.sh` instructions and hygiene
* remove extra loop in `wdl` for bash, matching zsh
* quote and escape all var expansions
* modernize CHANGELOG to markdown, ISO dates
* add note about using `direxpand` for bash
* remove old TODOs that won't work (mostly due to inconsistency
   between env vars, aliases, and persisted slot values across shells.)
* Switch to 0BSD License

### 2.2 - 2019-09-26
* Improve zsh support

### 2.1 - 2010-13-11
* rewrote file reading with advice from Wayne Seguin
* reformatted and fixed some code style issues

### 2.0 - 2010-20-10
* completed single-file, pure bash rewrite (no longer needs perl)
* env. vars now auto-update
* clear a single slot with a dot: `wds3 .`

### 1.12 - 2010-06-10
* Hosting on github
* Updated README
* zsh compatibility fixes by Matt Fletcher

### 1.11 - 2004-19-03
* fixed wdenv bug with spaces in dir names
* added bash completion to `wdscheme`

### 1.10 - 2004-24-02
* fixed quoting in `wdaliases.sh`
* fixed `WDSCHEME` usage for local scheme use
* released to sourceforge.net

### 1.09 - 2003-12-03
* added Gary Cramblitt's man page
* fixed install script for Solaris
* fixed bug when passing a dir. to `wds`
* updated `readme.txt` a little

### 1.08 - 2003-11-19
* fixed `wdscheme.pl -s` check (thanks Dave and Frank!)
* now effectively enforces 10 lines in all commands
* copies readme.txt to dist dir on install

### 1.07 - 2003-11-16
* fixed `wdenv` by making it a separate script as well
* made `wdenv` only export slots that are filled
* actually removed `wd.list` and `wd.dest` (from CVS too :)

### 1.06 - 2003-11-10
* made `wdl` a script instead of a plain alias
* wdscheme now unsets WDSCHEME
* fixed tarball root dir
* updated readme
* made all scripts use new `wdscheme.pl` for figuring the current scheme.
* removed unused `wd.list` and `wd.dest`

### 1.05 - 2003-11-08
* made recall of empty `wd` entry not `cd`
* better error handling of schemes deleted while they are active
* removed `WDSCHEME` env var from default script use (still checked
   on recall, for manual override)

### 1.0 - 2003-10-01
* initial release