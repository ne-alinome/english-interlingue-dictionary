" convert_data_to_asciidoctor.vim
"
" This file is part of the projects
" "Diccionario español-interlingüe" and
" "English-Interlingue Dictionary"
" (http://ne.alinome.net).
"
" By Marcos Cruz (programandala.net)

" This Vim program converts the source data to the Asciidoctor format.

" Last modified 20211224T1233+0100.
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
		let type = ''
	else
		let type = '*'.type.'*: '
	endif

	if headword != previous_headword
		" The record is a new headword.
		call setline(line_number,'- .'.headword.'.')
		if definition != ''
			call append(line_number,type.definition.'.')
		else
			call append(line_number,type)
		endif
		let line_number = line_number+1
	else
		" The record is a new usage or meaning of the current headword.
		call setline(line_number,type.definition.'.')
	endif

	let previous_headword = headword
	let line_number = line_number+1

endwhile

" ==============================================================
" Change log

" 2021-06-06: Start.
"
" 2021-12-23: Support example types, whose type indicator has the "-example"
" suffix.
"
" 2021-12-24: Finish the handling of example types. Change the handling of
" records with empty fields. Improve documentation.
