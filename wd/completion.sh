#
# wd completion command
#
_wdschemecomplete()
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

#TODO: list slots (wdl) to complete wd<TAB>
