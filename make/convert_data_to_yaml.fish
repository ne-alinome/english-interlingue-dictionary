#!/usr/bin/env fish

# convert_data_to_yaml.vim
#
# This file is part of the project
# "English-Interlingue Dictionary"
# (http://ne.alinome.net).
#
# By Marcos Cruz (programandala.net)

# This fish program converts the source data to the YAML format.

# Last modified 20220617T1655+0200.
# See change log at the end of the file.

# ==============================================================

set output $argv[]

set previous_headword ''
set previous_type ''
set indent_level 0
set listing_examples false

function indent
	echo (string repeat --no-newline --count $indent_level '  ')
end

while read line

	set headword   (string split --field 1 --allow-empty '#' "$line")
	set type       (string split --field 2 --allow-empty '#' "$line")
	set definition (string split --field 3 --allow-empty '#' "$line")

	# XXX FIXME `string trim` fails with error "unknown option -- in command
	# substitution" when the trimmed string starts with a hyphen,
	# e.g. the definition of a suffix; the workaround is to add a leading
	# space to it:

	set headword   (string trim " $headword")
	set type       (string trim " $type")
	set definition (string trim " $definition")

	if string match --quiet '*-example' "$type"

		# The type of the entry is "example".

		if not $listing_examples
			# Start a list of examples.
			set listing_examples true
			set indent_level (math $indent_level+1)
			echo (indent)"examples:"
			set indent_level (math $indent_level+1)
		end

		set example     (string trim (string split --field 1 ':' $definition))
		set translation (string trim (string split --field 2 ':' $definition))
		echo (indent)"- example:     $example"
		echo (indent)"  translation: $translation"
	
	else

		# The type of the entry is not "example".
	
		if $listing_examples
			# Deactivate the current listing of examples.
			set listing_examples false
			set indent_level (math $indent_level-2)
		end

		if not test "$headword" = "$previous_headword"
			# The entry is a new headword.
			set previous_headword "$headword"
			echo '---'
			echo (indent)"entry: $headword"
		end

		echo (indent)"- function: $type"
		if test -n "$definition"
			echo (indent)"  translation: $definition"
		end

	end

end

# ==============================================================
# Change log

# 2022-06-16: Start, based on <convert_data_to_yaml.vim>.
#
# 2022-06-17: First working version.

# vim: filetype=fish
