# Makefile

# This file is part of the project
# "English-Interlingue Dictionary"
# (http://ne.alinome.net)
#
# By Marcos Cruz (programandala.net)

# Last modified: 20220616T2047+0200.
# See change log at the end of the file.

# ==============================================================
# Requirements {{{1

# Asciidoctor (by Dan Allen, Sarah White et al.)
#   http://asciidoctor.org

# Asciidoctor EPUB3 (by Dan Allen and Sarah White)
#   http://github.com/asciidoctor/asciidoctor-epub3

# Asciidoctor PDF (by Dan Allen and Sarah White)
#   http://github.com/asciidoctor/asciidoctor-pdf

# dbtoepub
#   http://docbook.sourceforge.net/release/xsl/current/epub/README

# dictfmt (by Rik Faith)
#   https://sourceforge.net/projects/dict/
#   http://dict.org

# dictzip (by Rik Faith)
#   https://sourceforge.net/projects/dict/
#   http://dict.org

# ebook-convert
#   manual.calibre-ebook.com/generated/en/ebook-convert.html

# ImageMagick (by ImageMagick Studio LCC)
#   http://imagemagick.org

# img2pdf (by Johannes 'josch' Schauer)
#   https://gitlab.mister-muffin.de/josch/img2pdf

# msort (by Bill Poser)
#   http://www.billposer.org/Software/msort.html

# Neovim (by Justin M. Keyes)
#   http://neovim.org

# Pandoc (by John MaFarlane)
#   http://pandoc.org

# sponge (by Colin Watson and Tollef Fog Heen)
#   https://joeyh.name/code/moreutils/

# xsltproc
#   http://xmlsoft.org/xslt/xsltproc.html

# ==============================================================
# Config {{{1

VPATH=./src:./target

book=english-interlingue_dictionary
title="English-Interlingue Dictionary"
lang="en"
editor="Marcos Cruz (programandala.net)"
publisher="ne alinome"
description=English-Interlingue Dictionary
version_file=src/VERSION.adoc
version=$(shell cat $(version_file)|grep ':revnumber:'|sed -e 's/:revnumber: *//')
description_and_version="$(description) v$(version)"

dict_basename=eng-ile
dict_data_url=http://ne.alinome.net

cover=$(book)_cover
cover_author="Charles Kemp\nF.R. Pope"
cover_title="English-\nInterlingue\nDictionary"

# ==============================================================
# Interface {{{1

.PHONY: default
default: dict epuba pdfa4 thumb wwwdoc

.PHONY: all
all: azw3 csv dict dbk epub odt pdf thumb yaml wwwdoc

.PHONY: clean
clean:
	rm -fr target/* tmp/*

.PHONY: cleandoc
cleandoc:
	rm -f $(shell find target -type f | \
		grep "target/\..*" -v | grep ".*\.\(jpg\|png\)" -v)
	rm -f $(shell find tmp -type f | \
		grep "tmp/\..*" -v | grep ".*\.\(jpg\|png\)" -v)

.PHONY: cleancover
cleancover:
	rm -f target/*.jpg tmp/*.png

# -------------------------------------

.PHONY: jargon
jargon: tmp/$(dict_basename).jargon

# XXX TODO Move adoc to <tmp>, because it's not ready to be reused, it has
# an include.

.PHONY: adoc
adoc: target/$(book).adoc

.PHONY: azw3
azw3: target/$(book).adoc.epub.azw3

.PHONY: csv
csv: target/$(book).csv

.PHONY: dict
dict: target/$(dict_basename).dict.dz

.PHONY: epub
epub: epuba

.PHONY: epuba
epuba: target/$(book).adoc.epub

.PHONY: epubd
epubd: target/$(book).adoc.dbk.dbtoepub.epub

.PHONY: epubp
epubp: target/$(book).adoc.dbk.pandoc.epub

.PHONY: epubx
epubx: target/$(book).adoc.dbk.xsltproc.epub

.PHONY: odt
odt: target/$(book).adoc.dbk.pandoc.odt

.PHONY: pdf
pdf: pdfa4 pdfletter

.PHONY: pdfa4
pdfa4: \
	target/$(book).adoc._a4.pdf

.PHONY: pdfletter
pdfletter: \
	target/$(book).adoc._letter.pdf

.PHONY: pdfz
pdf: pdfa4z pdfletterz

.PHONY: pdfa4z
pdfa4z: \
	target/$(book).adoc._a4.pdf.zip \
	target/$(book).adoc._a4.pdf.gz

.PHONY: pdfletterz
pdfletterz: \
	target/$(book).adoc._letter.pdf.zip \
	target/$(book).adoc._letter.pdf.gz

.PHONY: dbk
dbk: target/$(book).adoc.dbk

.PHONY: yaml
yaml: target/$(book).yaml

# -------------------------------------

.PHONY: cover
cover: target/$(cover).jpg

.PHONY: thumb
thumb: target/$(cover)_thumb.jpg

# ==============================================================
# Sort the original data {{{1

.PHONY: sort
sort:
	msort \
		--line \
		--field-separators '#' \
		--position 1.1 \
		--position 2.1 \
		--position 3.1 \
		--comparison-type lexicographic \
		--in src/$(book).txt \
		--out tmp/$(book).MSORT.txt

tmp/$(book)._sorted.txt: src/$(book).txt
	msort \
		--line \
		--field-separators '#' \
		--position 1.1 \
		--position 2.1 \
		--position 3.1 \
		--comparison-type lexicographic \
		--in $< \
		--out $@

# ==============================================================
# Convert the original data to Asciidoctor {{{1

.SECONDARY: tmp/$(book)._sorted.txt
.SECONDARY: tmp/$(book)._sorted.txt.adoc
.SECONDARY: tmp/$(book).txt.adoc

tmp/%._sorted.txt.adoc: tmp/%._sorted.txt
	nvim -es -S make/convert_data_to_asciidoctor.vim $< -c 'w! $@|q!'

tmp/%.txt.adoc: tmp/%._sorted.txt.adoc
	nvim -S make/add_letter_headings.vim $< -c 'w! $@|q!'

# XXX FIXME Somehow <make/add_letter_headings.vim> does not work fine in ex
# mode. These commands add only the "A" heading:
#
# nvim -es -S make/add_letter_headings.vim $< -c 'w! $@|q!'
#
# nvim -es $< -S make/add_letter_headings.vim -c 'w! $@|q!'
#
# vim -e -s $< -S make/add_letter_headings.vim -c 'w! $@|q!'

target/$(book).adoc: \
	src/header.adoc \
	tmp/${book}.txt.adoc
	cat $^ > $@

# ==============================================================
# Convert the original data to YAML {{{1

.SECONDARY: tmp/$(book)._sorted.txt
.SECONDARY: tmp/$(book)._sorted.txt.yaml

tmp/%._sorted.txt.yaml: tmp/%._sorted.txt
	nvim -R -s make/convert_data_to_yaml.vim $< > $@

target/$(book).yaml: \
	tmp/${book}._sorted.txt.yaml
	cat $^ > $@

# ==============================================================
# Convert the original data to CSV {{{1

target/%.csv: src/%.txt
	sed -e 's/^\(.\+\) *#\(.\+\)\?#\(.\+\)#.*/"\1","\2","\3"/'  $< > $@

# ==============================================================
# Convert Asciidoctor to DocBook {{{1

.SECONDARY: target/$(book).adoc.dbk

%.adoc.dbk: %.adoc
	asciidoctor \
		--backend=docbook5 \
		--attribute format=e-book \
		--out-file=$@ $<

# ==============================================================
# Convert Asciidoctor to EPUB {{{1

%.adoc.epub: %.adoc target/$(cover).jpg
	asciidoctor-epub3 \
		--out-file=$@ $<

# ==============================================================
# Convert Asciidoctor to PDF {{{1

.SECONDARY: \
	tmp/$(book).adoc._a4.pdf \
	tmp/$(book).adoc._letter.pdf

tmp/%.adoc._a4.pdf: target/%.adoc tmp/$(cover).pdf
	asciidoctor-pdf \
		--out-file=$@ $<

tmp/%.adoc._letter.pdf: target/%.adoc tmp/$(cover).pdf
	asciidoctor-pdf \
		--attribute pdf-page-size=letter \
		--out-file=$@ $<

target/%.adoc._a4.pdf: tmp/%.adoc._a4.pdf
	@ln --force $< $@

target/%.adoc._letter.pdf: tmp/%.adoc._letter.pdf
	@ln --force $< $@

target/%.pdf.zip: tmp/%.pdf
	zip -9 $@ $<

target/%.pdf.gz: tmp/%.pdf
	gzip -9 --stdout $< > $@

# ==============================================================
# Convert DocBook to EPUB {{{1

# XXX OLD Deprecated.

# ------------------------------------------------
# With dbtoepub

%/$(book).adoc.dbk.dbtoepub.epub: \
	%/$(book).adoc.dbk \
	src/$(book)-docinfo.xml
	dbtoepub \
		--output $@ $<

# ------------------------------------------------
# With pandoc

target/$(book).adoc.dbk.pandoc.epub: \
	target/$(book).adoc.dbk \
	src/$(book)-docinfo.xml \
	src/pandoc_epub_template.txt \
	src/pandoc_epub_stylesheet.css­\
	target/$(cover).jpg
	pandoc \
		--from docbook \
		--to epub3 \
		--template=src/pandoc_epub_template.txt \
		--css=src/pandoc_epub_stylesheet.css \
		--variable=lang:$(lang) \
		--variable=editor:$(editor) \
		--variable=publisher:$(publisher) \
		--variable=description:$(description_and_version) \
		--epub-cover-image=target/$(cover).jpg \
		--output $@ $<

# ------------------------------------------------
# With xsltproc

%.adoc.dbk.xsltproc.epub: %.adoc.dbk
	rm -fr tmp/xsltproc/* && \
	xsltproc \
		--output tmp/xsltproc/ \
		/usr/share/xml/docbook/stylesheet/docbook-xsl/epub/docbook.xsl \
		$< && \
	echo -n application/epub+zip > tmp/xsltproc/mimetype && \
	cd tmp/xsltproc/ && \
	zip -0 -X ../../$@.zip mimetype && \
	zip -rg9 ../../$@.zip META-INF && \
	zip -rg9 ../../$@.zip OEBPS && \
	cd - && \
	mv $@.zip $@

# XXX TODO Find out how to pass parameters and their names, from the XLS:
#    --param epub.ncx.filename testing.ncx \

# XXX TODO Add the stylesheet. The XLS must be modified first,
# or the resulting XHTML must be modified at the end.
#  cp -f src/xsltproc/stylesheet.css tmp/xsltproc/OEBPS/ && \

# ==============================================================
# Convert DocBook to OpenDocument {{{1

%.adoc.dbk.pandoc.odt: \
	%.adoc.dbk \
	src/$(book)-docinfo.xml \
	src/pandoc_odt_template.txt
	pandoc \
		--from docbook \
		--to odt \
		--template=src/pandoc_odt_template.txt \
		--variable=lang:$(lang) \
		--variable=editor:$(editer) \
		--variable=publisher:$(publisher) \
		--variable=description:$(description_and_version) \
		--output $@ $<

# ==============================================================
# Convert EPUB to AZW3 {{{1

target/%.epub.azw3: target/%.epub
	ebook-convert $< $@

# ==============================================================
# Convert the original data to jargon {{{1

.SECONDARY: tmp/dict_header.adoc.dbk

tmp/dict_%.adoc.dbk: src/%.adoc
	asciidoctor \
		--backend=docbook5 \
		--attribute format=DICT \
		--out-file=$@ $<

.SECONDARY: tmp/dict_header.adoc.dbk.txt

tmp/%.adoc.dbk.txt: tmp/%.adoc.dbk
	pandoc -f docbook -t plain -o $@ $<

.SECONDARY: tmp/$(dict_basename).jargon

tmp/$(dict_basename).jargon: \
	tmp/$(book)._sorted.txt \
	tmp/dict_header.adoc.dbk.txt
	cp -f $< $@
	nvim -es -S make/convert_data_to_jargon.vim $@ -c 'wq!'
	cat tmp/dict_header.adoc.dbk.txt $@ | sponge $@

# ==============================================================
# Convert dictionary data to dict format {{{1

target/%.dict: tmp/%.jargon
	echo $(description_and_version)
	dictfmt \
		--utf8 \
		-u $(dict_data_url) \
		-s $(description_and_version) \
		-j $(basename $@) \
		< $<

# ==============================================================
# Install and uninstall dict {{{1

%.dict.dz: %.dict
	dictzip --force $<

.PHONY: install
install: target/$(dict_basename).dict.dz
	cp --force \
		$< \
		$(addsuffix .index, $(basename $(basename $^))) \
		/usr/share/dictd/
	/usr/sbin/dictdconfig --write
	/etc/init.d/dictd restart

.PHONY: uninstall
uninstall:
	rm --force /usr/share/dictd/$(dict_basename).*
	/usr/sbin/dictdconfig --write
	/etc/init.d/dictd restart

# ==============================================================
# Create the cover image {{{1

include Makefile.cover_image

# ==============================================================
# Build the release archives {{{1

branch=$(book)
prerequisites=*.adoc target/

include Makefile.release

# ==============================================================
# Online documentation {{{1

# Online documentation displayed on the Fossil repository.

.PHONY: wwwdoc
wwwdoc: wwwreadme

.PHONY: cleanwww
cleanwww:
	rm -f \
		doc/www/* \
		tmp/README.*

.PHONY: wwwreadme
wwwreadme: doc/www/README.html

doc/www/README.html: tmp/README.html
	echo "<div class='fossil-doc' data-title='README'>" > $@;\
	cat $< >> $@;\
	echo "</div>" >> $@

tmp/README.html: README.adoc
	asciidoctor \
		--embedded \
		--out-file=$@ $<

# ==============================================================
# Change log {{{1

# 2019-02-06: Start. Make DICT.
#
# 2019-02-13: Make Asciidoctor, DocBook, PDF and EPUB.
#
# 2019-02-24: Update the name of the project and the filenames.
#
# 2019-02-27: Fix metadata parameters of pandoc. Replace ISO 639-1 'ie' code
# with ISO-639-3 'ile' in the DICT file name, after the usual convention in
# collections of DICT dictionaries. Reuse the header in the DICT format. Don't
# use xsltproc by default.
#
# 2019-03-05: Update the URL of the original data of the DICT format.
#
# 2019-03-09: Add an interface command "odt" for OpenDocument. Reorder the
# interface commands.
#
# 2019-03-26: Update to the new format of the data.
#
# 2019-04-01: Fix sed expression to ignore comments.
#
# 2019-08-21: Fix sed expression to accept empty word-type fields. Formerly
# those records were added to the previous one, ruining the output.
#
# 2019-08-24: Update: field separator "|" now is "#", and the first field has a
# trailing space.
#
# 2019-09-15: Fix the sed expression that converts the original text data file
# to dictfmt's input format. The bug was introduced on 2019-08-24. Update the
# filename extension of the data file, from TSV to TXT.
#
# 2020-04-06: Improve requirements list. Replace DocBook extension "xml" with
# "dbk". Update the publisher. Build an EPUB also with Asciidoctor EPUB3.
# Change the names of the PDF versions to make both of them be listed together.
# 2020-08-23: Add a dot also at the end of the headwords, in e-book formats.
#
# 2020-08-24: Build a cover image. Use it with Asciidoctor EPUB3 and
# Asciidoctor PDF. Deprecate the conversions from DocBook to EPUB. Add a main
# "default" rule to build only the usual formats. Convert EPUB to AZW3.
#
# 2020-08-26: Build also a CSV data file. Compress the PDF with zip and gzip.
# Deprecate the conversions from DocBook to EPUB.
#
# 2020-08-27: Convert the semicolons into vertical bars in the Asciidoctor
# document.
#
# 2020-08-28: Move the cover image rules to an independent file. Fix author on
# the cover. Improve the compression of PDF files and keep them also
# uncompressed in <tmp>.
#
# 2020-11-05: Include <Makefile.release>.
#
# 2020-11-14: Update to the new vesion of <Makefile.release>.
#
# 2020-12-05: Update the conversion of the original data, ignoring the trailing
# spaces of the headword.
#
# 2020-12-24: Build an online version of the README file for the Fossil repository.

# 2021-06-06: Update the requirements: add dictfmt and dictzip.
#
# 2021-06-08: Make sure the data is sorted before converting it. Add a rule to
# clean the temporary and target files except those of the cover. Separate the
# building of the compressed and uncompressed PDF files; built the uncompressed
# PDF files by default. Update to the data-to-jargon and data-to-asciidoctor
# converters used by the "Diccionario español-interlingüe project, which
# combine all identical headwords into one single entry. Add the version number
# to the description. Use Neovim instead of Vim.
#
# 2021-12-23: Split into two steps the conversion from the original data into
# Asciidoctor.
#
# 2021-12-24: Use msort instead of sort.
#
# 2022-06-16: Add rules to convert the original data to YAML.
