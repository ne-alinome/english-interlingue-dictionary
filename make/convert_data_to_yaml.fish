#!/usr/bin/env fish

# convert_data_to_yaml.vim
#
# This file is part of the project
# "English-Interlingue Dictionary"
# (http://ne.alinome.net).
#
# By Marcos Cruz (programandala.net)

# This fish program converts the source data to the YAML format.

# Last modified 20220617T0038+0200.
# See change log at the end of the file.

# ==============================================================

set output $argv[]

set line_number 1
set previous_headword ''

while read line

	# if string match --quiet '*##*' "$line"
	# 	echo "WARNING: blank field in line $line_number:"
	# 	echo $line
	# end

	set headword   (string split --field 1 --allow-empty '#' "$line")
	set type       (string split --field 2 --allow-empty '#' "$line")
	set definition (string split --field 3 --allow-empty '#' "$line")

	# XXX FIXME This fails when the string starts with a hyphen,
	# e.g. the definition of a suffix, because fish interprets it
	# as an option of `string trim`; the solution is to add a leading
	# space:

	set headword   (string trim " $headword")
	set type       (string trim " $type")
	set definition (string trim " $definition")

	if string match --quiet '*-example' "$type"
		# The type of the entry is "example", used just to force
		# the proper sorting, not to be displayed.
		set type 'example'
	end

	if not test "$headword" = "$previous_headword"
		# The record is a new headword.
		set previous_headword "$headword"
		echo "$headword:"
	end

	if test -n "$definition"
		echo "  - $type: $definition"
	else
		echo "  - $type"
	end

	set line_number (math $line_number+1)

end

# ==============================================================
# Change log

# 2022-06-16: Start, based on <convert_data_to_yaml.vim>.
#
# 2022-06-17: First working version.

# vim: filetype=fish
