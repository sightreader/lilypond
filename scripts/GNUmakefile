depth = ..

SUBDIRS=build

SEXECUTABLES=convert-ly lilypond-book abc2ly etf2ly midi2ly lilypond-invoke-editor musicxml2ly lilysong lilymidi

STEPMAKE_TEMPLATES = lilypond script help2man po
HELP2MAN_EXECS = $(SEXECUTABLES)

AT_FILES=relocate-preamble
at-ext=.py
at-dir=$(top-build-dir)/python/$(outdir)

include $(depth)/stepmake/stepmake.make
include $(stepmake)/executable-targets.make
