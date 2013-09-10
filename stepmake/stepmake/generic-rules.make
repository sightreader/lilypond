$(outdir)/%: %.m4
	$(M4) $< > $@

%.gz: %
    @ $(call PRINT_SMART_DESC,gzip)
	@ gzip -c9 $< > $@

$(outdir)/%.css: $(CSS_DIRECTORY)/%.css
	@ $(call PRINT_GENERIC_DESC,Hard-linking,$@)
	@ ln -f $< $@
