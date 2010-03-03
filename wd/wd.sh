#!/bin/bash
echo "START"
# If no WDHOME is set, make it the default of ~/.wd
if [ -z "$WDHOME" ]
then
  export WDHOME="$HOME/.wd"
  echo "Using $WDHOME as \$WDHOME"
fi

# If there is no valid current scheme, assume 'default'
if [ -L "$WDHOME/current" -a -d "$WDHOME/current" ]
then
  if [ -z "$WDSCHEME" ]
  then
    export WDSCHEME=`readlink "$WDHOME/current"|cut -b $((${#WDHOME}+2))-`    
  fi
else
  if [ -z "$WDSCHEME" ]
  then
    echo "No scheme set, using 'default'"
    export WDSCHEME=default
  fi
fi

function _current_wdscheme_dir() {
  echo "$WDHOME/$WDSCHEME"
}

function _create_wdscheme () {
  if [ ! -d `_current_wdscheme_dir` ]
  then
    echo "Creating new scheme $WDSCHEME"
    mkdir -p `_current_wdscheme_dir`
    if [ -L "$WDHOME/current" -a -d "$WDHOME/current" ]
    then
      cp -r "$WDHOME/current"/* `_current_wdscheme_dir`/
    fi
  fi
  
  # remake the link for current wdscheme
  rm $WDHOME/current
  ln -s `_current_wdscheme_dir` $WDHOME/current    
}

# Make the scheme dir and link it to current if not already done
if [ ! -d "$WDHOME/current" ]
then
  _create_wdscheme
fi

# Function to store directories 
function wdstore () {
  local slot dir
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
  local slot
  if [ -z "$1" ]
  then
    slot="0"
  else
    slot="$1"
  fi

  if [ -e "$WDHOME/current/$slot" ]
  then
    cd -P "$WDHOME/current/$slot"
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

alias wdl="`which ls` -l "$WDHOME/'$WDSCHEME'"|cut -d' ' --complement -f 1,2,3,4,5,6,7|tail -n +2"

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
		COMPREPLY=()
		cur=${COMP_WORDS[COMP_CWORD]}		
		COMPREPLY=( $( compgen -d "$WDHOME/$cur"|grep -v '/current$'|cut -b $((${#WDHOME}+2))-) )
}
complete -o nospace -F _wdschemecomplete wdscheme

if [ ! -z $ls_alias ]
then
  alias ls=$ls_alias
fi

alias wdc="rm `_current_wdscheme_dir`/*"

echo "..FINISH"
