#!/bin/bash

# If no WDHOME is set, make it the default of ~/.wd
if [ -z "$WDHOME" ]
then
  export WDHOME="$HOME/.wd"
  echo "Using $WDHOME as \$WDHOME"
fi

# If there is no current scheme, assume 'default'
if [ -z "$WDSCHEME" ]
then
  if [ -z "$WDHOME/current" ]; then
    echo "No scheme set, using 'default'"
    export WDSCHEME=default
  else
    export WDSCHEME=`readlink $WDHOME/current|awk -F '/' '{print $5;}'`
  fi
fi

function _create_wdscheme () {
  if [ ! -d $WDHOME/$WDSCHEME ]
  then
    echo "Creating new scheme $WDSCHEME"
    mkdir -p $WDHOME/$WDSCHEME
  fi
  
  rm $WDHOME/current
  ln -s $WDHOME/$WDSCHEME $WDHOME/current    
}

# Make the scheme dir and link it to current if not already done
if [ ! -d "$WDHOME/current" ]
then
  _create_wdscheme
fi

# Function to store directories 
function wdstore () {
  if [ -z "$1" ]
  then
    echo "You must specify a slot."
  else
    if [ -e $WDHOME/current/$1 ]
    then
      rm $WDHOME/current/$1
    fi
    ln -fs `pwd` $WDHOME/current/$1
  fi
  
  # Make the alias for chdir-ing into the new slot
  alias wd${1}="wdretr $1"
  #alias wds${1}="wdstore $1"
  export WD${1}=`pwd`
}

function wdretr () {
  if [ -z "$1" ]
  then
    d="0"
  else
    d="$1"
  fi

  if [ -e "$WDHOME/current/$d" ]
  then
    cd -P "$WDHOME/current/$d"
  fi  
}
  
alias wds='wdstore 0'
for i in 1 2 3 4 5 6 7 8 9
do
  alias wds$i="wdstore $i"
done

alias wd='wdretr 0'
for i in `ls ~/.wd/current`
do
  alias wd$i="wdretr $i"
done

alias wdl="ls -l $WDHOME/current/|cut -d' ' --complement -f 1,2,3,4,5,6,7|tail -n +2"

function wdscheme () {
  if [ -z "$1" ]
  then
    echo $WDSCHEME
  else
    export WDSCHEME="$1"
    _create_wdscheme
  fi
}
