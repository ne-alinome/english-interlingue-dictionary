# Makefile of _Dictionarium Anglesi-Interlingue_

# By Marcos Cruz (programandala.net)

# Last modified 201902061935
# See change log at the end of the file

# ==============================================================
# Requirements

# - asciidoctor
# - asciidoctor-pdf
# - dbtoepub
# - dictfmt
# - pandoc
# - xsltproc

# ==============================================================
# Config

VPATH=./src:./target

book=dictionarium_anglesi-interlingue
title="Dictionarium Anglesi-Interlingue"
editor="Marcos Cruz (programandala.net)"
publisher="ne.alinome"
description=

dict_data_url=http://
dict_data_format=c5

# ==============================================================
# Interface

.PHONY: all
all: epub pdf

.PHONY: epub
epub: epubd epubp epubx

.PHONY: epubd
epubd: target/$(book).adoc.xml.dbtoepub.epub

.PHONY: epubp
epubp: target/$(book).adoc.xml.pandoc.epub

.PHONY: epubx
epubx: target/$(book).adoc.xml.xsltproc.epub

.PHONY: pdf
pdf: pdfa4 pdfletter

.PHONY: pdfa4
pdfa4: target/$(book).adoc.a4.pdf

.PHONY: pdfletter
pdfletter: target/$(book).adoc.letter.pdf

.PHONY: $(dict_data_format)
$(dict_data_format): tmp/dictionarium_anglesi-interlingue.$(dict_data_format)

.PHONY: dict
dict: target/dictionarium_anglesi-interlingue.dict.dz

.PHONY: clean
clean:
	rm -f target/* tmp/*

# ==============================================================
# Convert Asciidoctor to PDF

target/%.adoc.a4.pdf: src/%.adoc
	asciidoctor-pdf \
		--out-file=$@ $<

target/%.adoc.letter.pdf: src/%.adoc
	asciidoctor-pdf \
		--attribute pdf-page-size=letter \
		--out-file=$@ $<

# ==============================================================
# Convert Asciidoctor to DocBook

.SECONDARY: tmp/$(book).adoc.xml

tmp/%.adoc.xml: src/%.adoc
	asciidoctor --backend=docbook5 --out-file=$@ $<

# ==============================================================
# Convert DocBook to EPUB

# ------------------------------------------------
# With dbtoepub

target/$(book).adoc.xml.dbtoepub.epub: \
	tmp/$(book).adoc.xml \
	src/$(book)-docinfo.xml
	dbtoepub \
		--output $@ $<

# ------------------------------------------------
# With pandoc

target/$(book).adoc.xml.pandoc.epub: \
	tmp/$(book).adoc.xml \
	src/$(book)-docinfo.xml \
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

target/%.adoc.xml.xsltproc.epub: tmp/%.adoc.xml
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

target/$(book).adoc.xml.pandoc.odt: \
	tmp/$(book).adoc.xml \
	src/$(book)-docinfo.xml \
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

.SECONDARY: tmp/$(book).$(dict_data_format)

# XXX REMARK -- Example:
tmp/%.$(dict_data_format): src/%.txt
	gforth make/convert_data.fs -e "run $< bye" > $@
	vim -e -S make/tidy_data.vim $@

# ==============================================================
# Convert dictionary data to dict format

target/$(book).dict: tmp/$(book).$(dict_data_ext)
	dictfmt \
		--utf8 \
		-u "$(dict_data_url)" \
		-s "$(description)" \
		-$(dict_data_ext) $(basename $@) \
		< $<

# ==============================================================
# Install and uninstall dict

%.dict.dz: %.dict
	dictzip --force $<

.PHONY: install
install: target/$(book).dict.dz
	cp --force \
		$< \
		$(addsuffix .index, $(basename $(basename $^))) \
		/usr/share/dictd/
	/usr/sbin/dictdconfig --write
	/etc/init.d/dictd restart

.PHONY: uninstall
uninstall:
	rm --force /usr/share/dictd/$(book).*
	/usr/sbin/dictdconfig --write
	/etc/init.d/dictd restart

# ==============================================================
# Change log

# 2019-02-06: Start.
