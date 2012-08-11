# title	   package specific rules
# file	   make/Rules.make

$(outdir)/%: %.in
	rm -f $@
	cat $< | sed $(sed-atfiles) | sed $(sed-atvariables) > $@

include $(stepmake)/substitute.make

$(outdir)/%: %.m4
	$(M4) $< > $@

%.gz: %
	gzip -c9 $< > $@

$(outdir)/%.css: $(CSS_DIRECTORY)/%.css
	ln -f $< $@
