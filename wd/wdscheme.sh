#!/bin/bash

# wdscheme
# used to manage stored directory schemes for wd.

# Record previous scheme
if [ -z "$WDSCHEME" ]; then
 prevscheme=`cat $WDHOME/currentscheme`
else
 prevscheme=$WDSCHEME
fi

if [ -z "$prevscheme" ]; then
  prevscheme=default
fi

# Check usage
wdfile=`cat $WDHOME/currentscheme`
if [ -z "$1" ]; then
  echo "Usage: wdscheme.sh <scheme-name>"
	echo "Current scheme is: $prevscheme";

else 

  # File used by previous scheme
	oldfile=$WDHOME/${prevscheme}.scheme
	if [ ! -e "$oldfile" ]; then
	  echo "Your current wdscheme ($oldfile) is missing."
		echo "Please fix it."
		OOPS=1
	fi

	if [ ! $OOPS ]; then
    # File used by newly chosen scheme
  	newfile=$WDHOME/$1.scheme

    # Check scheme existance
		if [ ! -f "$newfile" ]; then
  		echo "Replicating current scheme to new: $1 "		
  		cp $oldfile $newfile
  	fi
  
    # Record new scheme choice to file for future start-up reference
	  echo $1 > $WDHOME/currentscheme

    # Assert the new scheme
		unset WDSCHEME
  fi
fi
