" add_letter_headings.vim
"
" This file is part of the project
" _English-Interlingue Dictionary_
" (http://ne.alinome.net)
"
" By Marcos Cruz (programandala.net)

" This Vim program adds the letter headings to the Asciidoctor version of the
" dictionary.

" 2019-02-13: Start.
" 2019-02-24: Update file header.
" 2021-12-23: Update to the current data format.

let fail=append(0,['// A {{{1','== A',''])

let letters=["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y"]

for letter in letters
  let next_letter=nr2char(char2nr(letter)+1)
  if search('^- \.'.letter.'.\+\n\(\*.\{-}\n\)\+'.'- \.'.next_letter,'We')
    let fail=append(line('.')-1,['','// '.next_letter.' {{{1','== '.next_letter,''])
  endif
endfor


