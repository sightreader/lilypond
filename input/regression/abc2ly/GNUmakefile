depth = ../../..

STEPMAKE_TEMPLATES = lilypond ly lysdoc abc documentation texinfo tex

TEXI2HTML_FLAGS += --nomenu

TMP = $(sort $(ABC_FILES) $(TEXINFO_SOURCES) )
COLLATED_FILES = ${TMP:%.abc=$(outdir)/%.ly}


include $(depth)/stepmake/stepmake.make

TITLE=abc2ly test suite
