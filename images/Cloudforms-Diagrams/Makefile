GRAPHVIZ_RENDERER=dot
GRAPHVIZ_OPTS=-Tpng
GRAPHVIZ_SOURCES=$(shell ls *.gv)
GRAPHVIZ_OUTPUT=$(GRAPHVIZ_SOURCES:.gv=.png)

.PHONY: clean png

png: $(GRAPHVIZ_OUTPUT)

test:
	echo $(TEST)

%.png: %.gv
	$(GRAPHVIZ_RENDERER) $(GRAPHVIZ_OPTS) $< -o $@

clean:
	rm -f $(GRAPHVIZ_OUTPUT)
