# special rules for the documentation section.
# There are too many to add to the general rules

.SUFFIXES: .1 .data .html .gif .png .tex .txt .xpm

$(outdir)/%.gif: %.xpm
    @ $(call PRINT_SMART_DESC,CONV)
	@ xpmtoppm $< | ppmtogif > $@

#isn't that error? shouldn't it be "ppmtopng" instead of "pnmtopng"?
#and do we really need that for anything?
$(outdir)/%.png: %.xpm
    @ $(call PRINT_SMART_DESC,CONV)
	@ xpmtoppm $< | pnmtopng > $@

# use striproff?
$(outdir)/%.txt: $(outdir)/%.1
    @ $(call PRINT_SMART_DESC,troff)
	@ troff -man -Tascii $< | grotty -b -u -o > $@

