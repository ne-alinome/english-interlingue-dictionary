" convert_data_to_yaml.vim
"
" This file is part of the projects
" "Diccionario español-interlingüe" and
" "English-Interlingue Dictionary"
" (http://ne.alinome.net).
"
" By Marcos Cruz (programandala.net)

" This Vim program converts the source data to the Asciidoctor format.

" Last modified 20220616T2042+0200.
" See change log at the end of the file.

" ==============================================================

let line_number = 1
let previous_headword = ''

while line_number <= line("$")

	let current_line = getline(line_number)

	if matchstr(current_line,'##') == '##'
		" The current line has an empty field.
		echo "WARNING: blank field in line" line_number.":"
		echo current_line
	endif

	let headword = matchstr(current_line,'^[^#]\+')
	let type = matchstr(current_line,'[^#]\+',len(headword)+1)
	let definition = matchstr(current_line,'[^#]\+',len(headword)+len(type)+2)

	let headword=trim(headword)
	let type=trim(type)
	let definition=trim(definition)

	if matchstr(type,'-example$') == '-example'
		" The type of the entry is "example", used just to force
		" the proper sorting, not to be displayed.
		let type = 'example'
	endif

	if headword != previous_headword
		" The record is a new headword.
		let previous_headword = headword
		echo headword.':'
	endif

	if definition != ''
		echo '  - '.type.': '.definition
	else
		echo '  - '.type
	endif

	let line_number = line_number+1

endwhile

quit

" ==============================================================
" Change log

" 2022-06-16: Start, based on <convert_data_to_asciidoctor.vim>.
