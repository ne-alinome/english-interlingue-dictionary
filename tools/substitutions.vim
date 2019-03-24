" substitutions.vim

" This file is part of the project
" _English-Interlingue Dictionary_
" (http://ne.alinome.net)
"
" By Marcos Cruz (programandala.net)

" This file is a repository of substitutions done in the dictionary, for
" reference and reusing.

" 2019-03-22: Separate entries by type:

%s@^\(.\{-}\)\t\(.\{-}\). \((\(v\|adj\|v\.n\|v\.t\|v\.a\|pron\|conj\|adv\|prep\)\.)\)@\1\t\2\r\1\t\3@c

" I forgot nouns and old-notation adjectives, so:

%s@^\(.\{-}\)\t\(.\{-}\). \((\(n\|a\)\.)\)@\1\t\2\r\1\t\3@c

" 2019-03-24: Search for duplicates that need a word type in the second one:

,$s@^\(\(.\+\)\t(.\+\n\2\t\)\([^(]\)@\1(adj\.) \3@c

" 2019-03-24: Add missing "(n.)" to most nouns:

:,$s@\t\([a-záéíóú-]\+\(on\|or\|e\|o\|a\|ion\|ia\|tá\|té\|um\|u\|ment\)\)\>@\t(n.) \1@c

:,$s@\t\([a-záéíóú-]\+\(ic\|al\|aci\|et\|at\|ut\|it\|il\|i\|t\)\)\>@\t(adj.) \1@c

:,$s@\t\([a-záéíóú-]\+\(men\)\)\>@\t(adv.) \1@c
