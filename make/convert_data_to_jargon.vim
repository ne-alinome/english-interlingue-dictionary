" convert_data_to_jargon.vim
"
" This file is part of the project
" "Diccionario español-interlingüe" and
" "English-Interlingue Dictionary"
" (http://ne.alinome.net).
"
" By Marcos Cruz (programandala.net)

" This Vim program converts the source data to the jargon format, which is one
" of the input formats accepted by dictfmt.

" Last modified 20210608T1734+0200.
" See change log at the end of the file.

" ==============================================================

let line_number = 1
let previous_headword = ''

while line_number <= line("$")
	let current_line = getline(line_number)
	if matchstr(current_line,'##') == '##'
		" The current line has an unfinished entry; delete it.
		call cursor(line_number,1)
		normal dd
		let line_number = line_number-1
	else
		" The current line has a valid entry; convert it.
		let headword = matchstr(current_line,'^[^#]\+')
		let type = matchstr(current_line,'[^#]\+',len(headword)+1)
		let definition = matchstr(current_line,'[^#]\+',len(headword)+len(type)+2)
		let headword=trim(headword)
		call setline(line_number,'')
		if headword != previous_headword
			call append(line_number,':'.headword.':')
			let line_number = line_number+1
		endif
		call append(line_number,'* '.type.': '.definition.'.')
		let line_number = line_number+1
		let previous_headword = headword
	endif
	let line_number = line_number+1
endwhile

" ==============================================================
" Change log

" 2021-06-06: Start.
