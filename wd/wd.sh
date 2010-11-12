#echo 'TODO'
#echo ' - remove aliases when slots are set to .'
#echo ' - only have wd* (retr) aliases for filled slots'
#echo ' - consider replacing wdretr with just cd $WD${i} ??'
#echo " - add prompt for wdc when WDC_ASK is set"
#echo " - allow schemes with spaces in the name"
#echo " - make wdschemecompletion not depend on sed"

# If no WDHOME is set, make it the default of ~/.wd
if [ -z "$WDHOME" ]
then
  export WDHOME="$HOME/.wd"
  echo "Using $WDHOME as \$WDHOME."
fi

function _wd_stored_scheme_name() {
  echo $(cat "$WDHOME/current_scheme")
}

function _wd_stored_scheme_filename() {
  echo "$WDHOME/$(_wd_stored_scheme_name).scheme"
}

function _wd_env_scheme_filename() {
  echo "$WDHOME/$WDSCHEME.scheme"
}

function _wd_set_stored_scheme() {
  echo $WDSCHEME > "$WDHOME/current_scheme"
}

function _wd_create_wdscheme() {
  echo "Creating new scheme $WDSCHEME"
  mkdir -p $WDHOME
  _wd_set_stored_scheme
  echo -e ".\n.\n.\n.\n.\n.\n.\n.\n.\n.\n" > $(_wd_env_scheme_filename)
}

function _wd_init_wdscheme() {
  if [ -f "$WDHOME/current_scheme" ]
  then
    if [ "$(_wd_stored_scheme_filename)" != "$(_wd_env_scheme_filename)" ] # we have a diff. scheme stored
    then
      echo "Cloning $(_wd_stored_scheme_filename) new scheme $WDSCHEME"
      cp "$(_wd_stored_scheme_filename)" "$(_wd_env_scheme_filename)" # clone it
      _wd_set_stored_scheme
    fi
  else
    _wd_create_wdscheme
  fi
}

function _wd_load_wdenv() {
  local slots _ifs_tmp i
  _ifs_tmp=$IFS
  IFS=$'\n'
  slots=( $(cat $(_wd_env_scheme_filename)) )
  for i in 0 1 2 3 4 5 6 7 8 9
  do
    if [ "${slots[$i]}" != "." ]
    then
      export WD${i}="${slots[$i]}"
    else
      unset WD${i}
    fi
  done
  IFS=$_ifs_tmp
}

# If there is no valid current scheme, assume 'default'
if [ ! -f "$WDHOME/$WDSCHEME.scheme" -o -z "$WDSCHEME" ] # we don't have it in the env.
then
  if [ -f "$WDHOME/current_scheme" ] # but we do have it stored
  then
    if [ -f $(_wd_stored_scheme_filename) ]
    then
      export WDSCHEME=$(_wd_stored_scheme_name) # load the stored scheme into the env.
    else
      _wd_create_wdscheme
    fi
  else
    echo "No scheme set, using 'default'."
    export WDSCHEME=default
  fi
fi

if [ -f "$WDHOME/current_scheme" ]
then
  # load current scheme slots
  _wd_load_wdenv                                      
else
  # Store the scheme file if it's not already there
  _wd_init_wdscheme
fi

function wdscheme() {
  if [ -z "$1" ]
  then
    echo "$WDSCHEME"
  else
    export WDSCHEME="$1"
    if [ -f "$WDHOME/${1}.scheme" ]
    then
      _wd_load_wdenv
      _wd_set_stored_scheme
    else
      _wd_init_wdscheme
    fi
    
  fi
}

function _wd_scheme_completion() {
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
complete -o nospace -F _wd_scheme_completion wdscheme

# Function to store directories 
function wdstore() {
  local slot dir slots _ifs_tmp i j
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
  
# Read the existing slots from the scheme file
  _ifs_tmp=$IFS
  IFS=$'\n'
  slots=( $(cat $(_wd_env_scheme_filename)) )
# Store the specified dir into the specified slot
  slots[$slot]="$dir"
# Write all slots back to the scheme file
  #for (( i = 0 ; i < ${#slots[@]} ; i++ ))
  for i in 0 1 2 3 4 5 6 7 8 9
  do
    (( j = $i + 1 ))
    if [ ! ${slots[$i]} == '' ]
    then
      echo "${slots[$i]}"
    else
      echo "."
    fi

  done > $(_wd_env_scheme_filename)
  IFS=$_ifs_tmp                                      

# Update the alias for the new slot
  alias wd${slot}="wdretr $slot"
# Store the new slot contents into the env.
  export WD${slot}="$dir"
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
  slots=( $(cat $(_wd_env_scheme_filename)) )
  IFS=$_ifs_tmp
  
  if [ ! ${slots[$slot]} == '.' ]
  then
    cd ${slots[$slot]}
  fi
}

function wdl() {
  local slots _ifs_tmp i j
  _ifs_tmp=$IFS
  IFS=$'\n'
  slots=( $(cat $(_wd_env_scheme_filename)) )
  IFS=$_ifs_tmp                                      
  for j in 0 1 2 3 4 5 6 7 8 9
  do
    if [ "${slots[$j]}" != "." ]
    then
      echo "${j} ${slots[$j]}"
    else
      echo "${j}"
    fi
  done
}

function wdc() {
  echo -e ".\n.\n.\n.\n.\n.\n.\n.\n.\n.\n" > $(_wd_env_scheme_filename)
  _wd_load_wdenv
}

alias wds='wdstore 0'
for i in 0 1 2 3 4 5 6 7 8 9
do
  alias wds$i="wdstore $i"
done
  
alias wd='wdretr 0'
for i in 0 1 2 3 4 5 6 7 8 9
do
  alias wd$i="wdretr $i"
done
