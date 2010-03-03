#!/bin/bash
local ls_alias
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
    # must be trying to store into slot 0
    slot="0"
  else
    slot=$1
  fi

  if [ -z "$2" ]
  then
    # one argument means store current dir in given slot
    dir=`pwd`
  else
    dir="$2"
  fi
  
  if [ -e "$WDHOME/current/$slot" ]
  then
    rm "$WDHOME/current/$slot"
  fi
  ln -fs "$dir" "$WDHOME/current/$slot"

  # Update the alias for the new slot
  alias wd${1}="wdretr $slot"
  # Store the new slot contents into the env.
  export WD${1}="$dir"
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
  
alias wds='wdstore'
for i in 0 1 2 3 4 5 6 7 8 9
do
  alias wds$i="wdstore $i"
done

alias wd='wdretr 0'
ls_alias=`alias ls 2> /dev/null`
if [ ! -z $ls_alias ]
then
  unalias ls
fi
  
for i in `ls $WDHOME/current/`
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

function _wdschemecomplete()
{
		local cur schemedir origdir
		origdir=${PWD}
		schemedir=${WDHOME}
		COMPREPLY=()
		cur=${COMP_WORDS[COMP_CWORD]}
		cd ${schemedir}
		COMPREPLY=( $( compgen -G "${cur}*.scheme" | sed 's/\.scheme//g') )
		cd ${origdir}
		return 0
}
complete -F _wdschemecomplete wdscheme

if [ ! -z $ls_alias ]
then
  alias ls=$ls_alias
fi

