setopt ksh_arrays
autoload -U compinit && compinit
autoload -U bashcompinit && bashcompinit

# If no WDHOME is set, make it the default of ~/.wd
if [[ -z "${WDHOME}" ]] ; then
  export WDHOME="${HOME}/.wd"
  echo "Using ${WDHOME} as \$WDHOME."
fi

# Prints the path to the file that holds the name of the current scheme.
# e.g. "~/.wd/current_scheme"
_wd_current_scheme_file()
{
  echo "${WDHOME}/current_scheme"
}

# Prints only the name of the current scheme.
# e.g. "project" (not the file path like "~/.wd/project.scheme").
# This may be temporary--when called from wdscheme,
# or it may come from the current scheme file,
# or it may be unset, in which case we use (and store) "default".
_wd_stored_scheme_name()
{
  local scheme
  if [[ -n "$_temp_wdscheme" ]] ; then
    echo "$_temp_wdscheme"
  else
    if [[ -n "$WDSCHEME" ]] ; then
      echo "$WDSCHEME"
    else
      if [[ -f "$(_wd_current_scheme_file)" ]] ; then
        exec 3< "$(_wd_current_scheme_file)"
        read scheme <&3
        echo "$scheme"
        exec 3<&-
        return
      else
        _wd_create_default_wdscheme
        _wd_stored_scheme_name
      fi
    fi
  fi
  unset _temp_wdscheme
}

# Print the path to the current scheme file, which may be constructed from the
# current scheme. The file is created if it doesn't already exist, and a
# default is used if no name is set.
# e.g. "~/.wd/myscheme.scheme"
_wd_stored_scheme_file()
{
  local name stored_scheme_filename
  name="$(_wd_stored_scheme_name)"
  stored_scheme_filename="${WDHOME}/${name}.scheme"
  if [[ -f "$stored_scheme_filename" ]] ; then

    echo "${stored_scheme_filename}"
  else
    _wd_create_wdscheme
    _wd_stored_scheme_file
  fi
}

# Stores "default" as the current scheme.
_wd_create_default_wdscheme()
{
  # Make current default
  echo 'default' > "$(_wd_current_scheme_file)"
}

# Stores the current scheme name and writes an empty scheme
# to the current scheme file, which either already exists or
# is created as "default".
_wd_create_wdscheme()
{
  if [[ ! -f "$(_wd_stored_scheme_file)" ]] ; then
    _wd_create_default_wdscheme
  fi
  echo "Creating new scheme $(_wd_stored_scheme_name)"
  if [[ ! -w "${WDHOME}" ]] ; then
    mkdir -p "${WDHOME}"
  fi
  echo "$(_wd_stored_scheme_name)" > "$(_wd_current_scheme_file)"
  echo -e ".\n.\n.\n.\n.\n.\n.\n.\n.\n.\n" > "$(_wd_stored_scheme_file)"
}

# Either duplicate the current scheme to the given scheme name and set it as current,
# or create a new, empty one with the given name.
_wd_init_wdscheme()
{
  if [[ -f "$(_wd_stored_scheme_file)" ]] ; then
    if [[ "$(_wd_stored_scheme_name)" != "$1" ]] ; then # we have a diff. scheme stored
      echo "Cloning $(_wd_stored_scheme_name) into new scheme ${1}"
      cp "$(_wd_stored_scheme_file)" "${WDHOME}/${1}.scheme" # clone it
    fi
  else
    _wd_create_wdscheme
  fi
}

# Set each non-empty slot into an environment variable with the same number, e.g $WD1
_wd_load_wdenv()
{
  setopt ksh_arrays
  local i line
  typeset -a slots
  while read -r line; do
    slots+=("$line")
  done < "$(_wd_stored_scheme_file)"

  for i in {0..9}; do
    if [[ "${slots[$i]}" != "." ]] ; then
      export "WD${i}=${slots[$i]}"
    else
      unset "WD${i}"
    fi
  done
  unsetopt ksh_arrays
}

# Load directory slots from the current scheme
_wd_load_wdenv

# Prints the current scheme or sets it to the given scheme name.
# If no argument is given and no scheme is set, sets the current
# scheme to "default".
wdscheme()
{
   local _temp_wdscheme shell_only
  if [[ -z "$1" ]] ; then
    _wd_load_wdenv # refresh env vars
    echo "$(_wd_stored_scheme_name)"
  else
    if [[ "-t" == "$1" ]] ; then
      shell_only=1
      shift
    fi

    if [[ -f "${WDHOME}/${1}.scheme" ]] ; then
      _temp_wdscheme="$1"
      
      if [[ -n $shell_only ]] ; then
        export WDSCHEME="$1"
      else
        echo "$1" > $(_wd_current_scheme_file)
      fi
      _wd_load_wdenv
    else
      _wd_init_wdscheme "$1"
    fi
  fi
}

# Use the list of scheme files to complete partial scheme names
# TODO: wdschmes can't have spaces for now
_wd_scheme_completion()
{
  local cur schemedir origdir schemelist
  origdir="${PWD}"
  schemedir="${WDHOME}"
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=()
  cd "${schemedir}"
  schemelist="$(compgen -G "${cur}*.scheme")"
  COMPREPLY=( ${schemelist//.scheme/} )
  cd "${origdir}"
}
complete -o nospace -F _wd_scheme_completion wdscheme

# Stores directory slots into the current scheme file
wdstore()
{
  setopt ksh_arrays
  local dir i line slot
  typeset -a slots
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
  while read -r line; do
    slots+=("$line")
  done < "$(_wd_stored_scheme_file)"

  # Store the specified dir into the specified slot
  slots[$slot]="$dir"
  # Write all slots back to the scheme file
  for i in {0..9}; do
    if [[ "${slots[$i]}" != '' ]] ; then
      echo "${slots[$i]}"
    else
      echo "."
    fi
  done > "$(_wd_stored_scheme_file)"

  # Update the alias for the new slot
  alias "wd${slot}=wdretr ${slot}"

  # Store the new slot contents into the env.
  export "WD${slot}=${dir}"
  unsetopt ksh_arrays
}

# Changes to the directory stored in the given slot of the current scheme file.
# If no slot is given, changes to the director in slot 0.
wdretr()
{
  setopt ksh_arrays
  local line slot
  typeset -a slots
  if [[ -z "$1" ]] ; then
    slot="0"
  else
    slot="$1"
  fi

  while read -r line; do
    slots+=("$line")
  done < "$(_wd_stored_scheme_file)"
  if [[ "${slots[$slot]}" != '.' ]] ;  then
    cd "${slots[$slot]}"
  fi
  unsetopt ksh_arrays
}

# Prints the contents of the slots in the current scheme file.
wdl()
{
  local index line
  index=0
  while read -r line; do
    if [[ "$line" != "." ]] ; then
      echo "${index} ${line}"
    else
      echo "$index"
    fi
    index=$((index + 1))
  done < "$(_wd_stored_scheme_file)"
}

# Clears all slots in the current scheme file.
wdc()
{
  echo -e ".\n.\n.\n.\n.\n.\n.\n.\n.\n.\n" > "$(_wd_stored_scheme_file)"
  _wd_load_wdenv
}

# Make wd and wds aliases in a function to prevent variable leakage
_wd_create_aliases()
{
  local i
  # Make store aliases wds[0-9], with the default alias "wds" the same as wds0.
  alias wds='wdstore 0'
  for i in {0..9}; do
    alias "wds${i}=wdstore ${i}"
  done

  # Make cd aliases wd[0-9], with the default alias "wd" the same as wd0.
  alias wd='wdretr 0'
  for i in {0..9}; do
    alias "wd${i}=wdretr ${i}"
  done
}

_wd_create_aliases
unsetopt ksh_arrays