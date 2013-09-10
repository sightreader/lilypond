$(outdir)/%: %.m4
	$(M4) $< > $@

%.gz: %
	$(HIDE) $(call PRINT_SMART_DESC,gzip)
	$(HIDE) gzip -c9 $< > $@

$(outdir)/%.css: $(CSS_DIRECTORY)/%.css
	$(HIDE) $(call PRINT_GENERIC_DESC,Hard-linking,$@)
	$(HIDE) ln -f $< $@
