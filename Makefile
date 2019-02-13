# Makefile of _Dictionarium Anglesi-Interlingue_

# By Marcos Cruz (programandala.net)

# Last modified 201902132312
# See change log at the end of the file

# ==============================================================
# Requirements

# - asciidoctor
# - asciidoctor-pdf
# - dbtoepub
# - dictfmt
# - make
# - pandoc
# - xsltproc

# ==============================================================
# Config

VPATH=./src:./target

book_basename=dictionarium_anglesi-interlingue
title="Dictionarium Anglesi-Interlingue"
editor="Marcos Cruz (programandala.net)"
publisher="ne.alinome"
description="English-Interlingue Dictionary"

dict_basename=eng-ie
dict_data_url=http://
dict_data_format=j

# ==============================================================
# Interface

.PHONY: all
all: dict epub pdf

.PHONY: it
it: dict epubp pdfa4

.PHONY: epub
epub: epubd epubp epubx

.PHONY: epubd
epubd: target/$(book_basename).adoc.xml.dbtoepub.epub

.PHONY: epubp
epubp: target/$(book_basename).adoc.xml.pandoc.epub

.PHONY: epubx
epubx: target/$(book_basename).adoc.xml.xsltproc.epub

.PHONY: pdf
pdf: pdfa4 pdfletter

.PHONY: pdfa4
pdfa4: target/$(book_basename).adoc.a4.pdf

.PHONY: pdfletter
pdfletter: target/$(book_basename).adoc.letter.pdf

.PHONY: $(dict_data_format)
$(dict_data_format): tmp/$(dict_basename).$(dict_data_format)

.PHONY: dict
dict: target/$(dict_basename).dict.dz

.PHONY: adoc
adoc: target/$(book_basename).adoc

.PHONY: xml
xml: target/$(book_basename).adoc.xml

.PHONY: clean
clean:
	rm -fr target/* tmp/*

# ==============================================================
# Convert Asciidoctor to PDF

%.adoc.a4.pdf: %.adoc
	asciidoctor-pdf \
		--out-file=$@ $<

%.adoc.letter.pdf: %.adoc
	asciidoctor-pdf \
		--attribute pdf-page-size=letter \
		--out-file=$@ $<

# ==============================================================
# Convert original data to Asciidoctor

.SECONDARY: tmp/$(book_basename).tsv.adoc

tmp/%.tsv.adoc: src/%.tsv
	sed -e "s/^\(.\+\)\t/- .\1: /" $< > $@
	vim -S make/add_letter_headings.vim $@

target/$(book_basename).adoc: \
	src/header.adoc \
	tmp/${book_basename}.tsv.adoc
	cat $^ > $@

# ==============================================================
# Convert Asciidoctor to DocBook

.SECONDARY: target/$(book_basename).adoc.xml

%.adoc.xml: %.adoc
	asciidoctor --backend=docbook5 --out-file=$@ $<

# ==============================================================
# Convert DocBook to EPUB

# ------------------------------------------------
# With dbtoepub

%/$(book_basename).adoc.xml.dbtoepub.epub: \
	%/$(book_basename).adoc.xml \
	src/$(book_basename)-docinfo.xml
	dbtoepub \
		--output $@ $<

# ------------------------------------------------
# With pandoc

%/$(book_basename).adoc.xml.pandoc.epub: \
	%/$(book_basename).adoc.xml \
	src/$(book_basename)-docinfo.xml \
	src/pandoc_epub_template.txt \
	src/pandoc_epub_stylesheet.css
	pandoc \
		--from docbook \
		--to epub3 \
		--template=src/pandoc_epub_template.txt \
		--css=src/pandoc_epub_stylesheet.css \
		--variable=lang:$(lang) \
		--variable=editor:$(author) \
		--variable=publisher:$(editor) \
		--variable=description:$(description) \
		--output $@ $<

# ------------------------------------------------
# With xsltproc

%.adoc.xml.xsltproc.epub: %.adoc.xml
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

# XXX TODO -- Find out how to pass parameters and their names, from the XLS:
#    --param epub.ncx.filename testing.ncx \

# XXX TODO -- Add the stylesheet. The XLS must be modified first,
# or the resulting XHTML must be modified at the end.
#  cp -f src/xsltproc/stylesheet.css tmp/xsltproc/OEBPS/ && \

# ==============================================================
# Convert DocBook to OpenDocument

%.adoc.xml.pandoc.odt: \
	%.adoc.xml \
	src/$(book_basename)-docinfo.xml \
	src/pandoc_odt_template.txt
	pandoc \
		--from docbook \
		--to odt \
		--template=src/pandoc_odt_template.txt \
		--variable=lang:$(lang) \
		--variable=editor:$(author) \
		--variable=publisher:$(editor) \
		--variable=description:$(description) \
		--output $@ $<

# ==============================================================
# Convert the original data file to "dict_data_format"

#.SECONDARY: tmp/$(dict_basename).$(dict_data_format)

# XXX REMARK -- Example:
#tmp/dictionarium_anglesi-interlingue.j: src/dictionarium_anglesi-interlingue.tsv
#tmp/%.j: src/%.tsv
tmp/$(dict_basename).$(dict_data_format): src/$(book_basename).tsv
	sed -e "s/^\(.\+\)\t/:\1:/" \
		$< > $@

# ==============================================================
# Convert dictionary data to dict format

target/%.dict: tmp/%.$(dict_data_format)
	dictfmt \
		--utf8 \
		-u $(dict_data_url) \
		-s $(description) \
		-$(dict_data_format) $(basename $@) \
		< $<

# ==============================================================
# Install and uninstall dict

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
# Change log

# 2019-02-06: Start. Make DICT.
#
# 2019-02-13: Make Asciidoctor, DocBook, PDF and EPUB.
