# Here are defined variables and functions for
# supressing superfluous make output and printing
# messages

# Fancy printing is controlled by make variables
# VERBOSE_MAKE, NO_FANCY_PRINTING and NOCOLORS, all disabled by default.
# Defining VERBOSE_MAKE shows all hidden output (echoing, some output from programs),
# excluding output from metafont (it can be turned on by VERBOSE_METAFONT variable).
# NO_FANCY_PRINTING turns off printing rule descriptions. It implies VERBOSE_MAKE.
# 
# NO_COLORS turns off color codes.

ifdef NO_FANCY_PRINTING
# NO_FANCY_PRINTING without VERBOSE_MAKE doesn't make sense.
override VERBOSE_MAKE=1
endif

# variable
ifdef VERBOSE_MAKE
HIDE :=
else
HIDE := @
endif

ifndef NO_COLORS
#check, if output is terminal
# Colors for fancy output - we are in terminal
# In facts, these may be styles, no only colors
STYLE_NONE := \e[0m# resets style
STYLE_GNRIC := \e[0;32m# generic description
STYLE_FNAME := \e[0;1;32m# file name
STYLE_PRGN := \e[0;1;33m# program name
STYLE_CXX := \e[0;32m# compilation description
STYLE_CP := \e[0;32m# copying description
STYLE_CONV := \e[0;32m# conversion description
STYLE_GEN := \e[0;32m# generation description
STYLE_LD := \e[0;32m# linkage description
STYLE_CPRESS := $(STYLE_GNRIC)# compression description
endif
# Color variables don't need to be defined, if we are not
# writing to terminal - they will behave as empty.
# Therefore, there is no 'else' clause

FP_ENDL := $(STYLE_NONE)\n# reset style + endline

#
# Functions for fancy output
#

# glossary:
# (to be extended)
#
# program, progname - name of program executed by make, e.g. g++, bison, mf
#

# function returning path to file relative to source root
# (not best way to do it, but works quite well)
FP_FULL_FNAME = $(subst $(abspath $(depth))/,,$(abspath $(1)))
FP_FULL_FNAMES = $(foreach filename,$(1),$(call FP_FULL_FNAME,$(filename)))
# function returning path to file, colored as filename
#FPW_FNAME = $(STYLE_FNAME)$(call FP_FULL_FNAME,$(1))
# function returning argument, colored as program name
#FPW_PRGN = $(STYLE_PRGN)$(1)

define PRINT_CMD_DESCRIPTION_PRINTF_ARGLIST
	$(if $(2),$(2)' ','') $(if $(3),$(3)' ','') $(if $(4),$(4)' ','') \
	$(if $(5),$(call FP_FULL_FNAMES,$(5))' ','') $(if $(6),$(6)' ','') \
	$(if $(7),$(call FP_FULL_FNAMES,$(7))' ','')
endef
# prints "<desc0> <prog> <desc1> <fn1> <desc2> <fn2>", with
#   <prog>    as PROGNAME
#   <fn*>     as FNAME
#   <desc*>   as <style>
#
# All arguments may be empty.
#
# The code may look overcomplicated, but it is all necessary.
# Ifs are necessary to avoid superfluous spaces, when arguments are absent,
# and to ensure correct argument matching. "if [ -t 1 ]" is necessary to
# avoid printing color codes, if output is not going to file
ifndef NO_FANCY_PRINTING
define PRINT_CMD_DESCRIPTION #<style>(1) <desc0>(2) <prog>(3) <desc1>(4) <fn1>(5) <desc2>(6) <fn2>(7)
	@- if [ -t 1 ];\
	then env printf "$(1)%s$(STYLE_PRGN)%s$(1)%s$(STYLE_FNAME)%s$(1)%s$(STYLE_FNAME)%s$(FP_ENDL)" $(PRINT_CMD_DESCRIPTION_PRINTF_ARGLIST);\
	else env printf "%s%s%s%s%s%s\n" $(PRINT_CMD_DESCRIPTION_PRINTF_ARGLIST);\
	fi
endef
else
PRINT_CMD_DESCRIPTION=
endif

# compilation, for which we want source file name (i.e. $<) printed
PRINTING_GROUP_1 := $(CC) $(CXX) $(BISON) $(FLEX) $(WINDRES)
#compilation, for which we want target file name (i.e. $@) printed
PRINTING_GROUP_2 := mf "\"$(METAFONT)\""
#copying
PRINTING_GROUP_3 := cp
#linking
PRINTING_GROUP_4 := ld
#compression
PRINTING_GROUP_5 := gzip zip
#conversion
PRINTING_GROUP_6 := help2man xpmtoppm ppmtogif pnmtopng
#special pseudo-names
PRINTING_GROUP_SPECIALS := _CONV
#all known names
PRINTING_GROUP_ALL = $(PRINTING_GROUP_1) $(PRINTING_GROUP_2) $(PRINTING_GROUP_3)\
    $(PRINTING_GROUP_4) $(PRINTING_GROUP_5) $(PRINTING_GROUP_6) $(PRINTING_GROUP_SPECIALS)

# This is real implementation of PRINT_SMART_DESC.
# PRINT_SMART_DESC is only proxy for handling optional arguments.
# Here, <$@>,<$<> and <$^>, means "$@,$<,$^, or whatever user specified to use instead".
# <usersources> and <usertarget> parameters let some rules use user-specified values,
# while not using automatic ones.
define PRINT_SMART_DESC_INTERNAL #<prog> <$@> <$<> <$^> <usersources> <usertarget>
	@#rules for defined groups are (descriptions above)
	@ $(if $(filter $(PRINTING_GROUP_1),$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_CXX),,$(1),compiling,$(3)))
	@ $(if $(filter $(PRINTING_GROUP_2),$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_CXX),,$(1),compiling,$(2)))
	@ $(if $(filter $(PRINTING_GROUP_3),$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_CP),,,Copying,$(2),from,$(3)))
	@ $(if $(filter $(PRINTING_GROUP_4),$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_LD),,,Linking,$(2)))
	@ $(if $(filter $(PRINTING_GROUP_5),$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_CPRESS),,$(1),compressing,$(2)))
	@ $(if $(filter $(PRINTING_GROUP_6),$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_CONV),,$(1),converting,$(3),to,$(2)))
	@ $(if $(filter _CONV,$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_CONV),,,Converting,$(3),to,$(2)))
	@# generic rule, for anything other (i.e. when <prog> is not empty)
	@ $(if $(filter-out "$(PRINTING_GROUP_ALL)",$(1)),$(call PRINT_CMD_DESCRIPTION,\
		$(STYLE_GEN),,$(1),generating,$(2),$(if $(5),from),$(5)))
	@# generic rule, when <prog> is empty
	@ $(if $(1),,$(call PRINT_CMD_DESCRIPTION,$(STYLE_GEN),,,Generating,$(2),$(if $(5),from),$(5)))
endef

# tries to deduce proper description from <prog>, and use $@, $< and $^.
# for empty <prog>, prints 'Generating $@'
# for special prog _CONV, prints 'Converting $< to $@'
#
# Optional argument <sources>, if present, is used instead of $< and $^.
# Optional argument <target>, if present, is used instead of $@.
define PRINT_SMART_DESC #<prog> <sources> <target>
	$(call PRINT_SMART_DESC_INTERNAL,$(1),"$(if $(3),$(3),$@)","$(if $(2),$(2),$<)","$(if $(2),$(2),$^)","$(2)","$(3)")
endef

#prints <desc> in STYLE_GNRIC style, optionally adding <fname> printed as filename
define PRINT_GENERIC_DESC #<desc> <fname>
	$(call PRINT_CMD_DESCRIPTION,$(STYLE_GNRIC),,,$(1),$(2))
endef