#!/bin/bash

# wdaliases 
#  A series of aliases for the wd commands
#  This file needs to be sourced from .bashrc or something similar
#

if [ -z "$WDHOME" ]; then
  export WDHOME=$HOME/.wd
fi

# add bash completion
source $WDHOME/completion.sh

# slurp current scheme
wdscheme=`cat $WDHOME/currentscheme`

if [ -z "$wdscheme" ]; then
  export wdscheme=default
fi

# Change to the default stored directory (position 0)
alias wd="cd \"\`$WDHOME/cdretr.rb 0\`\""
alias wd0='wd'

# wd1-wd9 change into their respective stored directories
alias wd1="cd \"\`$WDHOME/cdretr.rb 1\`\""
alias wd2="cd \"\`$WDHOME/cdretr.rb 2\`\""
alias wd3="cd \"\`$WDHOME/cdretr.rb 3\`\""
alias wd4="cd \"\`$WDHOME/cdretr.rb 4\`\""
alias wd5="cd \"\`$WDHOME/cdretr.rb 5\`\""
alias wd6="cd \"\`$WDHOME/cdretr.rb 6\`\""
alias wd7="cd \"\`$WDHOME/cdretr.rb 7\`\""
alias wd8="cd \"\`$WDHOME/cdretr.rb 8\`\""
alias wd9="cd \"\`$WDHOME/cdretr.rb 9\`\""

# Store the current directory into the default position
alias wds='$WDHOME/cdstore.rb 0'
alias wds0='wds'

# wds1-wds9 store the current directory the respective position (1-9)
alias wds1='$WDHOME/cdstore.rb 1'
alias wds2='$WDHOME/cdstore.rb 2'
alias wds3='$WDHOME/cdstore.rb 3'
alias wds4='$WDHOME/cdstore.rb 4'
alias wds5='$WDHOME/cdstore.rb 5'
alias wds6='$WDHOME/cdstore.rb 6'
alias wds7='$WDHOME/cdstore.rb 7'
alias wds8='$WDHOME/cdstore.rb 8'
alias wds9='$WDHOME/cdstore.rb 9'

# wdl lists all 10 stored directories for the current scheme.
alias wdl='$WDHOME/wdlist.rb'

# wdc clears the stored list of directories
alias wdc=">\"\`$WDHOME/wdscheme.rb\`\""

# changes schemes: wdscheme <scheme>
alias wdscheme='. $WDHOME/wdscheme.sh'

# dumps working dirs to environment vars
alias wdenv="$WDHOME/wdenv.rb > $WDHOME/wdenv && . $WDHOME/wdenv"

