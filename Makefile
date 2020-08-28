# Makefile of _English-Interlingue Dictionary_

# This file is part of the project
# _English-Interlingue Dictionary_
# (http://ne.alinome.net)
#
# By Marcos Cruz (programandala.net)

# Last modified 202008281825
# See change log at the end of the file

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

# ebook-convert
#   manual.calibre-ebook.com/generated/en/ebook-convert.html

# ImageMagick (by ImageMagick Studio LCC)
#   http://imagemagick.org

# img2pdf (by Johannes 'josch' Schauer)
#   https://gitlab.mister-muffin.de/josch/img2pdf

# Pandoc (by John MaFarlane)
#   http://pandoc.org

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
description="English-Interlingue Dictionary"

dict_basename=eng-ile
dict_data_url=http://ne.alinome.net
dict_data_format=j

cover=$(book)_cover
cover_author="Charles Kemp\nF.R. Pope"
cover_title="English-\nInterlingue\nDictionary"

# ==============================================================
# Interface {{{1

.PHONY: default
default: dict epuba pdfa4 thumb

.PHONY: all
all: azw3 csv dict dbk epub odt pdf thumb

.PHONY: clean
clean:
	rm -fr target/* tmp/*

# -------------------------------------

.PHONY: $(dict_data_format)
$(dict_data_format): tmp/$(dict_basename).$(dict_data_format)

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
	target/$(book).adoc._a4.pdf.zip \
	target/$(book).adoc._a4.pdf.gz

.PHONY: pdfletter
pdfletter: \
	target/$(book).adoc._letter.pdf.zip \
	target/$(book).adoc._letter.pdf.gz

.PHONY: dbk
dbk: target/$(book).adoc.dbk

# -------------------------------------

.PHONY: cover
cover: target/$(cover).jpg

.PHONY: thumb
thumb: target/$(cover)_thumb.jpg

.PHONY: cleancover
cleancover:
	rm -f target/*.jpg tmp/*.png

# ==============================================================
# Convert the original data to Asciidoctor {{{1

.SECONDARY: tmp/$(book).txt.adoc

tmp/%.txt.adoc: src/%.txt
	sed -e "s/^\(.\+\) \+#\(.\+\)\?#\(.\+\)#.*/- .\1. (\2): \3/"  $< | \
	sed -e "s/; / |{nbsp}/g" > $@
	vim -S make/add_letter_headings.vim $@

target/$(book).adoc: \
	src/header.adoc \
	tmp/${book}.txt.adoc
	cat $^ > $@

# ==============================================================
# Convert the original data to CSV {{{1

target/%.csv: src/%.txt
	sed -e 's/^\(.\+\) \+#\(.\+\)\?#\(.\+\)#.*/"\1","\2","\3"/'  $< > $@

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
		--variable=description:$(description) \
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
		--variable=description:$(description) \
		--output $@ $<

# ==============================================================
# Convert EPUB to AZW3 {{{1

target/%.epub.azw3: target/%.epub
	ebook-convert $< $@

# ==============================================================
# Convert the original data to "dict_data_format" {{{1

.SECONDARY: tmp/dict_header.adoc.dbk

tmp/dict_%.adoc.dbk: src/%.adoc
	asciidoctor \
		--backend=docbook5 \
		--attribute format=DICT \
		--out-file=$@ $<

.SECONDARY: tmp/dict_header.adoc.dbk.txt

tmp/%.adoc.dbk.txt: tmp/%.adoc.dbk
	pandoc -f docbook -t plain -o $@ $<

.SECONDARY: tmp/$(dict_basename).$(dict_data_format)

tmp/$(dict_basename).$(dict_data_format): \
	src/$(book).txt \
	tmp/dict_header.adoc.dbk.txt
	cat tmp/dict_header.adoc.dbk.txt > $@
	sed -e "s/^\(.\+\) *#\(.\+\)#\(.\+\)#/:\1:(\2): \3/" \
		$< >> $@

# ==============================================================
# Convert dictionary data to dict format {{{1

target/%.dict: tmp/%.$(dict_data_format)
	dictfmt \
		--utf8 \
		-u $(dict_data_url) \
		-s $(description) \
		-$(dict_data_format) $(basename $@) \
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
