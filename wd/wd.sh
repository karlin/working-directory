#echo 'TODO'
#echo ' - remove aliases when slots are set to .'
#echo ' - only have wd* (retr) aliases for filled slots'
#echo ' - consider replacing wdretr with just cd $WD${i} ??'
#echo " - add prompt for wdc when WDC_ASK is set"
#echo " - allow schemes with spaces in the name"
#echo " - make wdschemecompletion not depend on sed"
#echo " - investigate issues with RVM on mac (no problem on linux, maybe?)"
#echo " - allow infinite slots"
#echo " - wdp & wdn: cd to previous or next slot if current dir is in current scheme"

# If no WDHOME is set, make it the default of ~/.wd
if [[ -z "$WDHOME" ]] ; then
  export WDHOME="$HOME/.wd"
  echo "Using $WDHOME as \$WDHOME."
fi

_wd_stored_scheme_name() 
{
  echo $(cat "$WDHOME/current_scheme")
}

_wd_stored_scheme_filename()
{
  if [[ ! -z $WDSCHEME && $WDSCHEME != $(_wd_stored_scheme_name) ]]; then
    echo $(_wd_env_scheme_filename)
  else
    echo "$WDHOME/$(_wd_stored_scheme_name).scheme"
  fi
}

_wd_env_scheme_filename()
{
  #if [[ $WDSCHEME != $(_wd_stored_scheme_name) ]]; then
  #  _wd_set_stored_scheme()
  #else
    echo "$WDHOME/$WDSCHEME.scheme"
  #fi
}

_wd_set_stored_scheme()
{
  echo "$1" > "$WDHOME/current_scheme"
}

_wd_create_wdscheme()
{
  echo "Creating new scheme $1"
  mkdir -p "$WDHOME"
  _wd_set_stored_scheme $1
  echo -e ".\n.\n.\n.\n.\n.\n.\n.\n.\n.\n" > "$(_wd_stored_scheme_filename)"
}

_wd_init_wdscheme()
{
  if [[ -f "$WDHOME/current_scheme" ]] ; then
    if [[ "$(_wd_stored_scheme_filename)" != "$WDHOME/${1}.scheme" ]] ; then # we have a diff. scheme stored
      echo "Cloning $(_wd_stored_scheme_filename) new scheme $1"
      echo "cp $(_wd_stored_scheme_filename) $WDHOME/${1}.scheme"
      cp "$(_wd_stored_scheme_filename)" "$WDHOME/${1}.scheme" # clone it
      _wd_set_stored_scheme $1
    fi
  else
    _wd_create_wdscheme
  fi
}

_wd_load_wdenv()
{
  local slots i index
  index=0
  while read -r line; do
    slots[$index]="$line"
    (( index = $index + 1 ))
  done < "$(_wd_stored_scheme_filename)"
  
  for i in 0 1 2 3 4 5 6 7 8 9 ; do
    if [[ "${slots[$i]}" != "." ]] ; then
      export WD${i}="${slots[$i]}"
    else
      unset WD${i}
    fi
  done
}

# If there is no valid current scheme, assume 'default'
if [[ ! -f "$WDHOME/$WDSCHEME.scheme" || -z "$WDSCHEME" ]] ; then # we don't have it in the env.
  if [[ -f "$WDHOME/current_scheme" ]] ; then # but we do have it stored
    if [[ -f "$(_wd_stored_scheme_filename)" ]] ; then
      #export WDSCHEME="$(_wd_stored_scheme_name)" # load the stored scheme into the env.
      echo "wd scheme is $(_wd_stored_scheme_name)"
    else
      _wd_create_wdscheme
    fi
  else
    echo "No scheme set, using 'default'."
    export WDSCHEME=default
  fi
fi

if [[ -f "$WDHOME/current_scheme" ]] ; then
  # load current scheme slots
  _wd_load_wdenv                                      
else
  # Store the scheme file if it's not already there
  _wd_init_wdscheme $WDSCHEME
fi

wdscheme()
{
  if [[ -z "$1" ]] ; then
    #echo $(_wd_stored_scheme_name)
    if [[ ! -z $WDSCHEME && $WDSCHEME != $(_wd_stored_scheme_name) ]]; then
      echo $WDSCHEME
    else
      echo "$(_wd_stored_scheme_name)"
    fi
  else
    #export WDSCHEME="$1"
    if [[ -f "$WDHOME/${1}.scheme" ]] ; then
      _wd_load_wdenv
      _wd_set_stored_scheme $1
    else
      _wd_init_wdscheme $1
    fi
  fi
}

_wd_scheme_completion()
{
  local cur schemedir origdir schemelist
  origdir=${PWD}
  schemedir=${WDHOME}
  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  # TODO could probably do this without cd to the scheme dir
  cd ${schemedir}
  schemelist="$(compgen -G "${cur}*.scheme")"
  COMPREPLY=( ${schemelist//.scheme/} )
  cd ${origdir}
}
complete -o nospace -F _wd_scheme_completion wdscheme

# Function to store directories 
wdstore()
{
  local slot dir slots i j index
  if [[ -z "$1" ]] ; then
    # must be trying to store into slot 0
    slot="0"
  else
    slot="$1"
  fi

  if [[ -z "$2" ]] ; then
    # one argument means store current dir in given slot
    dir="$(pwd)"
  else
    dir="$2"
  fi
  
  # Read the existing slots from the scheme file
  index=0
  while read -r line; do
    slots[$index]="$line"
    (( index = $index + 1 ))
  done < "$(_wd_stored_scheme_filename)"

  # Store the specified dir into the specified slot
  slots[$slot]="$dir"
  # Write all slots back to the scheme file
  #for (( i = 0 ; i < ${#slots[@]} ; i++ ))
  for i in 0 1 2 3 4 5 6 7 8 9 ; do
    (( j = $i + 1 ))
    if [[ "${slots[$i]}" != '' ]] ; then
      echo "${slots[$i]}"
    else
      echo "."
      unalias wd${slot}
    fi

  done > "$(_wd_stored_scheme_filename)"

# Update the alias for the new slot
  alias wd${slot}="wdretr $slot"
# Store the new slot contents into the env.
  export WD${slot}="$dir"
}

wdretr()
{
  local slot slots index
  if [[ -z "$1" ]] ; then
    slot="0"
  else
    slot="$1"
  fi

  index=0
  while read -r line; do
    slots[$index]="$line"
    (( index = $index + 1 ))
  done < "$(_wd_stored_scheme_filename)"
  if [[ "${slots[$slot]}" != '.' ]] ;  then
    cd "${slots[$slot]}"
  fi
}

wdl()
{
  local slots i j index
  index=0
  while read -r line; do
    slots[$index]="$line"
    (( index = $index + 1 ))
  done < "$(_wd_stored_scheme_filename)"

  for j in 0 1 2 3 4 5 6 7 8 9 ; do
    if [[ "${slots[$j]}" != "." ]] ; then
      echo "${j} ${slots[$j]}"
    else
      echo "${j}"
    fi
  done
}

wdc()
{
  echo -e ".\n.\n.\n.\n.\n.\n.\n.\n.\n.\n" > "$(_wd_stored_scheme_filename)"
  _wd_load_wdenv
}

alias wds='wdstore 0'
for i in 0 1 2 3 4 5 6 7 8 9 ; do
  alias wds$i="wdstore $i"
done
  
alias wd='wdretr 0'
for i in 0 1 2 3 4 5 6 7 8 9 ; do 
  alias wd$i="wdretr $i"
done
