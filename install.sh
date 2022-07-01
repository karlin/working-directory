#!/bin/sh
if [ ! -d "$HOME" ]; then
  echo You must have \$HOME set first.
fi

mkdir -p "${HOME}/.wd"
cp -i ./wd/* "${HOME}/.wd"
cp ./README.md "${HOME}/.wd"
if [ -d "${HOME}/.wd" ]; then
  echo Done copying. To use wd, add it to your .bashrc/.zshrc file:
	echo
	echo \#\#\# Tell wd where to find schemes \(any shell\):
	echo export WDHOME=\"\$\{HOME\}/.wd\"
	echo
	echo \#\#\# ...use it in bash:
	echo source \"\$\{WDHOME\}/wd.sh\"
	echo shopt -s direxpand \# optional, for \$WD[0-9] env. var. completion
	echo
	echo \#\#\# ...use it in zsh:
	echo source \"\$\{WDHOME\}/wd.zsh\"
	echo
	echo Please copy wd.1.gz into your man page directory if you want to use it.
	echo
else
  echo "Installation FAILED, could not create ${HOME}/.wd"
fi
