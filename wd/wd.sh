#!/bin/bash

# If no WDHOME is set, make it the default of ~/.wd
if [ -z "$WDHOME" ]
then
  export WDHOME="$HOME/.wd"
  echo "Using $WDHOME as \$WDHOME."
fi

function _stored_scheme_name() {
  echo $(cat "$WDHOME/current_scheme")
}

function _stored_scheme_filename() {
  echo "$WDHOME/$(_stored_scheme_name).scheme"
}

function _stored_scheme() {
  cat $(_stored_scheme_filename)
}

function _env_scheme_filename() {
  echo "$WDHOME/$WDSCHEME.scheme"
}

# If there is no valid current scheme, assume 'default'
if [ ! -f "$WDHOME/$WDSCHEME.scheme" -o -z "$WDSCHEME" ] # we don't have it in the env.
then
  if [ -f "$WDHOME/current_scheme" -a -f $(_stored_scheme_filename) ] # but we do have it stored
  then
    export WDSCHEME=$(_stored_scheme_name) # load the stored scheme into the env.
  else
    echo "No scheme set, using 'default'."
    export WDSCHEME=default
  fi
fi

function _create_wdscheme() {
  if [ -f "$WDHOME/current_scheme" ] # we have a scheme stored
  then
    cp $(_stored_scheme_filename) $(_env_scheme_filename) # clone it     
  else
    echo "Creating new scheme $WDSCHEME"
    echo $WDSCHEME > "$WDHOME/current_scheme" # store the scheme name in a file
    echo "- - - - - - - - - -" > $(_env_scheme_filename)
  fi
}

# Store the scheme file if it's not already there
if [ ! -f "$WDHOME/current_scheme" ]
then
  _create_wdscheme
fi

function wdscheme() {
  if [ -z "$1" ]
  then
    echo "$WDSCHEME"
  else
    export WDSCHEME="$1"
    _create_wdscheme
  fi
}

function _wdschemecomplete() {
  local cur schemedir origdir
  origdir=${PWD}
  schemedir=${WDHOME}
  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  cd ${schemedir}
  COMPREPLY=( $( compgen -G "${cur}*.scheme" | sed 's/\.scheme//g') )
  #COMPREPLY=${COMPREPLY[@]%.scheme}
  cd ${origdir}
}
complete -o nospace -F _wdschemecomplete wdscheme

#alias wdl='cat $(_stored_scheme_filename)'


# Function to store directories 
function wdstore() {
  local slot dir slots _ifs_tmp
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
    dir="$(pwd)"
  else
    dir="$2"
  fi
  
  _ifs_tmp=$IFS
  IFS=$'\n'
  slots=( $(cat $(_env_scheme_filename)) )
  slots[$slot]="$dir"

  for (( i = 0 ; i < ${#slots[@]} ; i++ ))
  do
    echo "${slots[$i]}"
  done > $(_env_scheme_filename)
  IFS=$_ifs_tmp                                      

  # Update the alias for the new slot
  alias wd${1}="wdretr $slot"
  # Store the new slot contents into the env.
  export WD${1}="$dir"
}

function wdretr() {
  local slot slots _ifs_tmp
  if [ -z "$1" ]
  then
    slot="0"
  else
    slot="$1"
  fi

  _ifs_tmp=$IFS
  IFS=$'\n'
  slots=( $(cat $(_env_scheme_filename)) )
  IFS=$_ifs_tmp                                     
  
  if [ ! ${slots[$slot]} == '-' ]
  then
    cd ${slots[$slot]}
  fi
}
  
alias wds='wdstore'
for i in 0 1 2 3 4 5 6 7 8 9
do
  alias wds$i="wdstore $i"
done

ls_alias=`alias ls 2> /dev/null`
if [ ! -z $ls_alias ]
then
  unalias ls
fi
  
#for (( i = 0 ; i < 10 ; i++ ))
for i in 0 1 2 3 4 5 6 7 8 9
do
  alias wd$i="wdretr $i"
done

function wdl() {
  local slots _ifs_tmp i
  _ifs_tmp=$IFS
  IFS=$'\n'
  slots=( $(cat $(_env_scheme_filename)) )
  for i in 0 1 2 3 4 5 6 7 8 9
  do
    if [ ! ${slots[$i]} == '-' ]
    then
      echo "$i ${slots[$i]}"
    else
      echo "$i"
    fi
  done
}

function wdscheme() {
  if [ -z "$1" ]
  then
    echo $WDSCHEME
  else
    export WDSCHEME="$1"
    _create_wdscheme
  fi
}

# function _wdschemecomplete()
# {
		# COMPREPLY=()
		# cur=${COMP_WORDS[COMP_CWORD]}		
		# COMPREPLY=( $( compgen -d "$WDHOME/$cur"|grep -v '/current$'|cut -b $((${#WDHOME}+2))-) )
# }
# complete -o nospace -F _wdschemecomplete wdscheme
 
if [ ! -z $ls_alias ]
then
  alias ls=$ls_alias
fi

function wdc() {
  if [ ! -z $WDC_ASK ]
  then
    > $(_env_scheme_filename)
  else
    > $(_env_scheme_filename)
  fi
}
