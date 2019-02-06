#!/bin/sh

# interlingue.sh

# A dict wrapper to search all of the Interlingue dictionaries that
# are installed in the DICT server, provided they include the word
# "interlingue" (case insensitive) in the description.

# This file is part of the project
# Dictionarium Anglesi-Interlingue
# (http://ne.alinome.net)

# By Marcos Cruz (programandala.net), 2019

# Usage
#
# Copy or link this file to a directory in your path, with your name
# of choice, e.g.  <~/bin/interlingue> or
# </usr/local/bin/interlingue>.

# Change log
#
# 2019-02-06: First version.

dictionaries=$(\
  dict -D | \
  grep "\<interlingue\>" --ignore-case |\
  sed -e "s/\s*\(\S\+\) .*/\1/"
  )

for dictionary in $dictionaries
do
  dict -d $dictionary $*
done
