" choose_headword_types.vim

" This file is part of the project
" _English-Interlingue Dictionary_
" (http://ne.alinome.net)
"
" By Marcos Cruz (programandala.net)

" This program searchs the data for missing headword types and asks the user.

" 2019-03-25: Start. First version.
"
" 2019-03-26: Update to the new data format (bars instead of tabs). Add
" 'expr.' and 'n.pl.' types. Add option 'x' to mark entry with 'FIXME'.

function! SetHeadwordType(type)

  " New data format:
  execute 'silent! substitute,|XXX|,|'.a:type.'|,'

endfunction

function! ChooseHeadwordTypes()

  let l:key=''

  while search('|XXX|',"cW")

    " Make sure the cursor is at the centre and redraw the screen
    normal z.
    redraw!

    echo "[a]dj. a[d]v. [c]onj. [e]xpr. [i]nterj. [n]. n.p[l]. [p]rep. p[r]on. [v]. fi[x] [Q]UIT"

    let l:key=nr2char(getchar())

    if l:key=="a"
      call SetHeadwordType("adj.")
    elseif l:key=="d"
      call SetHeadwordType("adv.")
    elseif l:key=="c"
      call SetHeadwordType("conj.")
    elseif l:key=="e"
      call SetHeadwordType("expr.")
    elseif l:key=="i"
      call SetHeadwordType("interj.")
    elseif l:key=="l"
      call SetHeadwordType("n.pl.")
    elseif l:key=="n"
      call SetHeadwordType("n.")
    elseif l:key=="p"
      call SetHeadwordType("prep.")
    elseif l:key=="r"
      call SetHeadwordType("pron.")
    elseif l:key=="v"
      call SetHeadwordType("v.")
    elseif l:key=="x"
      silent! substitute,|XXX|,||,e
      silent! substitute,|$,|XXX FIXME,e
    elseif l:key=="Q"
      break
    else
      " Next line:
      normal j
    endif

  endwhile

endfunction

set cursorline
call ChooseHeadwordTypes()

