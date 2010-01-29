#!/bin/sh
if [ ! -d "$HOME" ]; then
  echo You must have \$HOME set first.
fi

mkdir $HOME/.wd
cp -i ./wd/* $HOME/.wd
cp README $HOME/.wd
if [ -d "$HOME/.wd" ]; then
  echo Done. Please add the following lines to your .bashrc file:
	echo
	echo export WDHOME=\$HOME/.wd
	echo source \$WDHOME/wdaliases.sh
	echo
	echo Please copy wd.1.gz into your man page directory if you want to use it.
	echo
else
  echo Installation FAILED, could not create $HOME/.wd
fi
