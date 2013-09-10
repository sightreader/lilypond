$(outdir)/%: %.m4
	$(M4) $< > $@

%.gz: %
	@ $(call FANCY_PRINT_GENERIC_WITH,gzip,packing,$@)
	@ gzip -c9 $< > $@

$(outdir)/%.css: $(CSS_DIRECTORY)/%.css
	@ $(call PRINT_GENERIC_DESC,Hard-linking,$@)
	@ ln -f $< $@
