#echo 'TODO'
#echo " - add prompt for wdc when WDC_ASK is set"
#echo " - allow infinite slots"

# If no WDHOME is set, make the default ~/.wd
if [[ -z "${WDHOME}" ]] ; then
  export WDHOME="${HOME}/.wd"
  echo "Using ${WDHOME} as \$WDHOME."
fi

_wd_stored_scheme_name()
{
  echo $(cat "${WDHOME}/current_scheme")
}

_wd_stored_scheme_filename()
{
  echo "${WDHOME}/$(_wd_stored_scheme_name).scheme"
}

_wd_env_scheme_filename()
{
  echo "${WDHOME}/${WDSCHEME}.scheme"
}

_wd_set_stored_scheme()
{
  echo "${WDSCHEME}" > "${WDHOME}/current_scheme"
}

_wd_create_wdscheme()
{
  echo "Creating new scheme ${WDSCHEME}"
  mkdir -p "${WDHOME}"
  _wd_set_stored_scheme
  echo -e ".\n.\n.\n.\n.\n.\n.\n.\n.\n.\n" > "$(_wd_env_scheme_filename)"
}

_wd_init_wdscheme()
{
  if [[ -f "${WDHOME}/current_scheme" ]] ; then
    if [[ "$(_wd_stored_scheme_filename)" != "$(_wd_env_scheme_filename)" ]] ; then # we have a diff. scheme stored
      echo "Cloning $(_wd_stored_scheme_filename) new scheme ${WDSCHEME}"
      cp "$(_wd_stored_scheme_filename)" "$(_wd_env_scheme_filename)" # clone it
      _wd_set_stored_scheme
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
    index=$((index + 1))
  done < "$(_wd_env_scheme_filename)"

  for (( i = 0 ; i < 10 ; i++ )); do
    if [[ "${slots[$i]}" != "." ]] ; then
      export "WD${i}=${slots[$i]}"
    else
      unset "WD${i}"
    fi
  done
}

# If there is no valid current scheme, assume 'default'
if [[ ! -f "${WDHOME}/${WDSCHEME}.scheme" || -z "${WDSCHEME}" ]] ; then # we don't have it in the env.
  if [[ -f "${WDHOME}/current_scheme" ]] ; then # but we do have it stored
    if [[ -f "$(_wd_stored_scheme_filename)" ]] ; then
      export WDSCHEME="$(_wd_stored_scheme_name)" # load the stored scheme into the env.
    else
      _wd_create_wdscheme
    fi
  else
    echo "No scheme set, using 'default'."
    export WDSCHEME=default
  fi
fi

if [[ -f "${WDHOME}/current_scheme" ]] ; then
  # load current scheme slots
  _wd_load_wdenv
else
  # Store the scheme file if it's not already there
  _wd_init_wdscheme
fi

wdscheme()
{
  if [[ -z "$1" ]] ; then
    echo "${WDSCHEME}"
  else
    export WDSCHEME="$1"
    if [[ -f "${WDHOME}/${1}.scheme" ]] ; then
      _wd_load_wdenv
      _wd_set_stored_scheme
    else
      _wd_init_wdscheme
    fi
  fi
}

_wd_scheme_completion()
{
  local cur schemedir origdir schemelist
  origdir="${PWD}"
  schemedir="${WDHOME}"
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  # TODO could probably do this without cd to the scheme dir
  cd "${schemedir}"
  schemelist="$(compgen -G "${cur}*.scheme")"
  COMPREPLY=( ${schemelist//.scheme/} )
  cd "${origdir}"
}
complete -o nospace -F _wd_scheme_completion wdscheme

# Function to store directories
wdstore()
{
  local slot dir slots i index
  if [[ -z "$1" ]] ; then
    # no slot given so use 0
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
    index=$((index + 1))
  done < "$(_wd_env_scheme_filename)"

  # Store the specified dir into the specified slot
  slots[$slot]="$dir"
  # Write all slots back to the scheme file
  for (( i = 0 ; i < 10 ; i++ )); do
    if [[ "${slots[$i]}" != '' ]] ; then
      echo "${slots[$i]}"
    else
      echo "."
    fi
  done > "$(_wd_env_scheme_filename)"

  # Update the alias for the new slot
  alias "wd${slot}=wdretr ${slot}"

  # Store the new slot contents into the env.
  export "WD${slot}=${dir}"
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
    index=$((index + 1))
  done < "$(_wd_env_scheme_filename)"
  if [[ "${slots[$slot]}" != '.' ]] ;  then
    cd "${slots[$slot]}"
  fi
}

wdl()
{
  local slots j index
  index=0
  while read -r line; do
    if [[ "$line" != "." ]] ; then
      echo "${index} $line"
    else
      echo "${index}"
    fi
    index=$((index + 1))
  done < "$(_wd_env_scheme_filename)"
}

wdc()
{
  echo -e ".\n.\n.\n.\n.\n.\n.\n.\n.\n.\n" > "$(_wd_env_scheme_filename)"
  _wd_load_wdenv
}

alias wds='wdstore 0'
for (( i = 0 ; i < 10 ; i++ )); do
  alias "wds${i}=wdstore ${i}"
done

alias wd='wdretr 0'
for (( i = 0 ; i < 10 ; i++ )); do
  alias "wd${i}=wdretr ${i}"
done
