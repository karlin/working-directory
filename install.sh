#!/bin/sh
if [ ! -d "$HOME" ]; then
  echo You must have \$HOME set first.
fi

mkdir -p $HOME/.wd
cp -i ./wd/* $HOME/.wd
cp ./README $HOME/.wd
if [ -d "$HOME/.wd" ]; then
  echo Done. Please add the following lines to your .bashrc/.zshrc file:
	echo
	echo export WDHOME=\$HOME/.wd
	echo source \$WDHOME/wd.sh #for bash
	echo    OR
	echo source \$WDHOME/wd.zsh #for zsh
	echo
	echo Please copy wd.1.gz into your man page directory if you want to use it.
	echo
else
  echo Installation FAILED, could not create $HOME/.wd
fi
