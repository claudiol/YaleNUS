TARGET=engagement
CUSTOMER=YaleNUS
PROJECT="YaleNUS Cloudforms and OpenStack Implementation - APAC"
ASCIIDOC=asciidoc
ASCIIDOC_DBLATEX_STY=./asciidoc/asciidoc-dblatex-custom.sty
ASCIIDOC_OPTS=-v
DBLATEX_OPTS=-V -Platex.hyperparam=colorlinks,linkcolor=blue,citecolor=blue,urlcolor=blue -Pdoc.publisher.show=0 -P latex.output.revhistory=0 -s $(ASCIIDOC_DBLATEX_STY)
ASCIIDOC_CONF="./asciidoc/xhtml11.conf"
OUTPUTDIR="./Documents/EngagementJournal"
GRAPHVIZ_SRCDIR="./images/Cloudforms-Diagrams"

.PHONY: clean diagrams html xml pdf

html: $(TARGET).html

xml: $(TARGET).xml

pdf: $(TARGET).pdf

epub: $(TARGET).epub

diagrams:
	cd $(GRAPHVIZ_SRCDIR) && make

%.html: %.adoc
	$(ASCIIDOC) --conf ${ASCIIDOC_CONF} $(ASCIIDOC_OPTS) -a customer="$(CUSTOMER)" -a project_title=$(PROJECT) -o $(OUTPUTDIR)/$(CUSTOMER)-$(TARGET).html $<

%.xml: %.adoc
	$(ASCIIDOC) -b docbook -d article $(ASCIIDOC_OPTS) -a customer="$(CUSTOMER)" -a project_title=$(PROJECT) -o $(OUTPUTDIR)/$(CUSTOMER)-$(TARGET).xml $<

%.pdf: %.xml
	a2x --verbose --icons -d book --asciidoc-opts="$(ASCIIDOC_OPTS)" --no-xmllint --dblatex-opts="$(DBLATEX_OPTS)" -D $(OUTPUTDIR)/ -f pdf $(OUTPUTDIR)/$(CUSTOMER)-$(TARGET).xml

clean:
	rm -f *~ $(OUTPUTDIR)/$(CUSTOMER)-$(TARGET).xml $(OUTPUTDIR)/$(CUSTOMER)-$(TARGET).pdf $(OUTPUTDIR)/$(CUSTOMER)-$(TARGET).html
	cd $(GRAPHVIZ_SRCDIR) && make clean

