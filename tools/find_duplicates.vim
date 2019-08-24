" find_duplicates.vim
"
" This file is part of the project
" _English-Interlingue Dictionary_
" (http://ne.alinome.net)
"
" By Marcos Cruz (programandala.net)
"
" This command finds duplicate entries in the source.
"
" 2019-08-24: Start.

call search('^\(.\{-}\)#\(.\{-}\)#.\+\n\1#\2#')
