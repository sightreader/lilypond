depth = ../../..

STEPMAKE_TEMPLATES = lilypond ly lysdoc midi documentation texinfo tex

TEXI2HTML_FLAGS += --nomenu

TMP = $(sort $(LY_FILES) $(TEXINFO_SOURCES) )
COLLATED_FILES = ${TMP:%.ly=$(outdir)/%-midi.ly}

include $(depth)/stepmake/stepmake.make

TITLE=MIDI test suite
