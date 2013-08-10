# special rules for the documentation section.
# There are too many to add to the general rules

.SUFFIXES: .1 .data .html .gif .png .tex .txt .xpm

$(outdir)/%.gif: %.xpm
	@ $(call FANCY_PRINT_CONVERSION_TO,$<,$@)
	@ xpmtoppm $< | ppmtogif > $@

#isn't that error? shouldn't it be "ppmtopng" instead of "pnmtopng"?
#and do we really need that for anything?
$(outdir)/%.png: %.xpm
	@ $(call FANCY_PRINT_CONVERSION_TO,$<,$@)
	@ xpmtoppm $< | pnmtopng > $@

# use striproff?
$(outdir)/%.txt: $(outdir)/%.1
	@ $(call FANCY_PRINT_GENERATION_WITH,troff,$@)
	@ troff -man -Tascii $< | grotty -b -u -o > $@

