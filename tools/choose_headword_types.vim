" choose_headword_types.vim

" This file is part of the project
" _English-Interlingue Dictionary_
" (http://ne.alinome.net)
"
" By Marcos Cruz (programandala.net)

" This program searchs the data for missing headword types and asks the user.

" 2019-03-25: Start. First version.

function! SetHeadwordType(type)

  execute 'silent! substitute,\t,\t'.a:type.' ,'

endfunction

function! ChooseHeadwordTypes()

  let l:key=''

  while search('\t[^(]',"cW")

    " Make sure the cursor is at the centre and redraw the screen
    normal z.
    redraw!

    echo "[a]dj. a[d]v. [c]onj. [i]nterj. [n]. ]rep. [v]. [Q]UIT"

    let l:key=nr2char(getchar())

    if l:key=="a"
      call SetHeadwordType("(adj.)")
    elseif l:key=="d"
      call SetHeadwordType("(adv.)")
    elseif l:key=="c"
      call SetHeadwordType("(conj.)")
    elseif l:key=="i"
      call SetHeadwordType("(interj.)")
    elseif l:key=="n"
      call SetHeadwordType("(n.)")
    elseif l:key=="p"
      call SetHeadwordType("(prep.)")
    elseif l:key=="v"
      call SetHeadwordType("(v.)")
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

