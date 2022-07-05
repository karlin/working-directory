#!/bin/zsh

# Working Directory (wd)
# See README.md for a description of this script

# wd is a shell utility, so exit if not interactive:
[[ $- != *i* ]] && return
setopt ksh_arrays
autoload -U compinit && compinit
autoload -U bashcompinit && bashcompinit
# When this script is sourced, clear any temporary scheme from the env:
unset WDSCHEME
# If no WDHOME is set, default to ~/.wd
if [[ -z "$WDHOME" ]] ; then
  export WDHOME="${HOME}/.wd"
  >&2 echo "wd: Using ${WDHOME} as \$WDHOME."
fi

WD_SLOT_LIMIT=10 # 0-9 for one-keystroke slot names; add more if you want!
WD_DEFAULT_SCHEME_NAME=default

# Print the path to the file that holds the name of the current scheme.
# e.g. "~/.wd/current_scheme"
_wd_current_scheme_file()
{
  local currentscheme
  if [[ ! -w "$WDHOME" ]] ; then
    mkdir -p "$WDHOME"
  fi
  currentscheme="${WDHOME}/current_scheme"
  if [[ ! -f "$currentscheme" ]] ; then
    echo "$WD_DEFAULT_SCHEME_NAME" > "$currentscheme"
  fi
  echo "$currentscheme"
}

# Print only the name of the current scheme.
# e.g. "project" (not the file path like "~/.wd/project.scheme".)
# This may be temporary--when called from wdscheme,
# or it may come from the current scheme file,
# or it may be unset, in which case we use (and store) a default.
_wd_stored_scheme_name()
{
  local scheme currentscheme_file
  if [[ -n "$_temp_wdscheme" ]] ; then
    echo "$_temp_wdscheme"
  else
    if [[ -n "$WDSCHEME" ]] ; then
      echo "$WDSCHEME"
    else
      currentscheme_file="$(_wd_current_scheme_file)"
      if [[ -f "$currentscheme_file" ]] ; then
        exec 7< "$currentscheme_file"
        read -r scheme <&7
        echo "$scheme"
        exec 7<&-
        return
      else
        >&2 echo "wd: no current scheme set, using default."
        _wd_use_default_scheme
        _wd_stored_scheme_name
      fi
    fi
  fi
  unset _temp_wdscheme
}

# Print the path of the current scheme file, constructed from the current
# scheme's name. The file is created if it doesn't already exist, and a
# default is used if no name is set.
# e.g. "~/.wd/myscheme.scheme"
_wd_stored_scheme_file()
{
  local name stored_scheme_filename
  name="$(_wd_stored_scheme_name)"
  stored_scheme_filename="${WDHOME}/${name}.scheme"
  if [[ -f "$stored_scheme_filename" ]] ; then
    echo "$stored_scheme_filename"
  else
    # There was no stored scheme--create a new scheme or use default
    if [[ "$name" == "$WD_DEFAULT_SCHEME_NAME" ]] ; then
      # The default is the one missing--create it now to prevent loops
      : > "${WDHOME}/${WD_DEFAULT_SCHEME_NAME}.scheme"
      _wd_create_wdscheme
    else
      >&2 echo "wd: scheme file '${stored_scheme_filename}' not found, using default."
      _wd_use_default_scheme
      # Call this function again now that a default was restored
      _wd_stored_scheme_file
    fi
  fi
}

# Store WD_DEFAULT_SCHEME_NAME as the current scheme.
_wd_use_default_scheme()
{
  echo "$WD_DEFAULT_SCHEME_NAME" > "$(_wd_current_scheme_file)"
  # Reset any env override
  unset WDSCHEME
}

# Store the current scheme name and write an empty scheme
# to the current scheme file, which either already exists or
# is created.
_wd_create_wdscheme()
{
  local i scheme scheme_file
  scheme="$(_wd_stored_scheme_name)"
  scheme_file="$(_wd_stored_scheme_file)"
  if [[ ! -f "$scheme_file" ]] ; then
    >&2 echo "wd: missing scheme file ${scheme_file}!"
    _temp_wdscheme="$name"
    _wd_use_default_scheme
  fi
  >&2 echo "wd: Creating new scheme ${scheme}"
  # Save the new scheme as current
  echo "$scheme" > "$(_wd_current_scheme_file)"
  if [[ -e "$scheme_file" ]] ; then
    >&2 echo "wd: new scheme already exists, not overwriting!"
    return
  fi
  # Fill in empty slots in the scheme file
  : > "$scheme_file"
  for (( i = 0 ; i < WD_SLOT_LIMIT ; i++ )); do
    echo -e "." >> "$scheme_file"
  done
}

# Either duplicate the current scheme to the given scheme name and set it as current,
# or create a new, empty one with the given name.
_wd_init_wdscheme()
{
  if [[ -f "$(_wd_stored_scheme_file)" ]] ; then
    if [[ "$(_wd_stored_scheme_name)" != "$1" ]] ; then
      # Different name, init a new scheme
      >&2 echo "wd: Cloning $(_wd_stored_scheme_name) into new scheme ${1}"
      cp "$(_wd_stored_scheme_file)" "${WDHOME}/${1}.scheme" # clone it
      echo "$1" > "$(_wd_current_scheme_file)"
    fi
  else
    _wd_create_wdscheme
  fi
}

# Set each non-empty slot into an environment variable with the same number, e.g $WD1
_wd_load_wdenv()
{
  setopt ksh_arrays
  local i line scheme_file
  typeset -a slots
  scheme_file="$(_wd_stored_scheme_file)"
  if [[ -f "$scheme_file" ]] ; then
    while read -r line; do
      slots+=("$line")
    done < "$scheme_file"
    for (( i = 0 ; i < WD_SLOT_LIMIT ; i++ )); do
      if [[ "${slots[$i]}" != "." ]] ; then
        export "WD${i}=${slots[$i]}"
      else
        unset "WD${i}"
      fi
    done
  else
    >&2 echo -n "wd: stored scheme is missing, falling back to: "
    _wd_use_default_scheme
    _wd_stored_scheme_name
    _wd_load_wdenv
  fi
  unsetopt ksh_arrays
}

# Load directory slots from the current scheme
_wd_load_wdenv

# Print the current scheme or sets it to the given scheme name.
# If no argument is given and no scheme is set, sets the current
# scheme to a default.
wdscheme()
{
  local _temp_wdscheme shell_only
  if [[ -z "$1" ]] ; then
    _wd_load_wdenv # refresh env vars
    _wd_stored_scheme_name
  else
    if [[ "-t" == "$1" ]] ; then
      shell_only=1
      shift
    else
      unset WDSCHEME
    fi
    if [[ -f "${WDHOME}/${1}.scheme" ]] ; then
      _temp_wdscheme="$1"
      if [[ -n $shell_only ]] ; then
        export WDSCHEME="$1"
      else
        echo "$1" > "$(_wd_current_scheme_file)"
        # unset WDSCHEME # TODO unset doesn't work inside subshell expansions
      fi
      _wd_load_wdenv
    else
      _wd_init_wdscheme "$1"
    fi
  fi
}

# Use the list of scheme files to complete partial scheme names
_wd_scheme_completion()
{
  local cur scheme_dir saved_dir schemes scheme_comp
  saved_dir="${PWD}"
  scheme_dir="${WDHOME}"
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=()
  cd "${scheme_dir}" || exit
  schemes="$(compgen -o nospace -o filenames -G "${cur}*.scheme")"
  local IFS=$'\n'
  for scheme_comp in $schemes; do
    # Remove any path chars added by compgen -o filenames
    scheme_comp="${scheme_comp//\/}"
    # Escape spaces with backslashes in scheme names so they fully complete
    scheme_comp="${scheme_comp// /\\ }"
    COMPREPLY+=( "${scheme_comp//.scheme}" )
  done
  cd "${saved_dir}" || exit
}
complete -o nospace -F _wd_scheme_completion wdscheme

# Store directory slots into the current scheme file
wdstore()
{
  setopt ksh_arrays
  local dir i line slot
  typeset -a slots
  if [[ -z "$1" ]] ; then
    # No slot given so use 0
    slot="0"
  else
    slot="$1"
  fi
  if [[ -z "$2" ]] ; then
    # One argument means store current dir in given slot
    dir="$(pwd)"
  else
    # Two args--store the first in the slot given by the second
    dir="$2"
  fi
  # Read the existing slots from the scheme file
  while read -r line; do
    slots+=("$line")
  done < "$(_wd_stored_scheme_file)"
  # Store the specified dir into the specified slot
  slots[$slot]="$dir"
  # Write all slots back to the scheme file
  for (( i = 0 ; i < WD_SLOT_LIMIT ; i++ )); do
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

# Change to the directory stored in the given slot of the current scheme file.
# If no slot is given, change to the directory in slot 0.
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
    cd "${slots[$slot]}" || exit
  fi
  unsetopt ksh_arrays
}

# Print directory slots from the current scheme file.
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

# Clear all slots in the current scheme file.
wdc()
{
  local i line scheme_file
  # TODO: prevent clearing default on fallback?
  scheme_file="$(_wd_stored_scheme_file)"
  # Show previous contents in case it was a mistake
  while read -r line; do
    echo "$line"
  done < "$scheme_file"
  >&2 echo "wd: ${scheme_file} cleared (previous file contents shown above)"
  # Truncate, then fill with empty slots
  : > "$scheme_file"
  for (( i = 0 ; i < WD_SLOT_LIMIT ; i++ )); do
    echo -e "." >> "$scheme_file"
  done
  # Load the newly-empty slots
  _wd_load_wdenv
}

# Make wd and wds aliases in a function to prevent variable leakage
_wd_create_aliases()
{
  local i
  # Make "store" aliases wds{0..n}, and "wds" as equivalent to "wds0".
  alias wds='wdstore 0'
  for (( i = 0 ; i < WD_SLOT_LIMIT ; i++ )); do
    alias "wds${i}=wdstore ${i}"
  done
  # Make cd aliases wd{0..n}, and "wd" as equivalent to "wd0".
  alias wd='wdretr 0'
  for (( i = 0 ; i < WD_SLOT_LIMIT ; i++ )); do
    alias "wd${i}=wdretr ${i}"
  done
}

_wd_create_aliases
unsetopt ksh_arrays