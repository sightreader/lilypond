# Here are defined variables and functions for
# supressing superfluous make output and printing
# messages

# defining variable NOCOLORS turns coloring off, despite of output type

# variable
ifdef VERBOSE_MAKE
HIDE :=
else
HIDE := @
endif

#ifneq ($(shell (if [ -t 1 ] ; then printf 1; fi)),)
ifndef NOCOLORS
USE_COLOR_CODES=1
endif
#endif

ifdef USE_COLOR_CODES
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
# function returning path to file, colored as filename
#FPW_FNAME = $(STYLE_FNAME)$(call FP_FULL_FNAME,$(1))
# function returning argument, colored as program name
#FPW_PRGN = $(STYLE_PRGN)$(1)

# prints "<desc0> <prog> <desc1> <fn1> <desc2> <fn2>", with
#   <prog>    as PROGNAME
#   <fn*>     as FNAME
#   <desc*>   as <style>
#
# All arguments may be empty.
ifndef NO_FANCY_PRINTING
define PRINT_CMD_DESCRIPTION #<style>(1) <desc0>(2) <prog>(3) <desc1>(4) <fn1>(5) <desc2>(6) <fn2>(7)
	@ env printf "$(1)%s$(STYLE_PRGN)%s$(1)%s$(STYLE_FNAME)%s$(1)%s$(STYLE_FNAME)%s$(FP_ENDL)"\
	$(if $(2),$(2)' ','') $(if $(3),$(3)' ','') $(if $(4),$(4)' ','') $(if $(5),$(call FP_FULL_FNAME,$(5))' ','') $(if $(6),$(6)' ','') $(if $(7),$(call FP_FULL_FNAME,$(7))' ','')
	@# ifs are necessary to avoid superfluous spaces, when arguments are absent, and to ensure correct argument matching
endef
else
PRINT_CMD_DESCRIPTION=
endif
# echo version:
#    @ env echo -ne "$(if $(2),$(1)$(2) ,)$(if $(3),$(call FPW_PRGN,$(3)) ,)"\
#        "$(if $(4),$(1)$(4) ,)$(if $(5),$(call FPW_FNAME,$(5)) ,)$(if $(6),$(1)$(6) ,)"\
#        "$(if $(7),$(call FPW_FNAME,$(7)) ,)$(FP_ENDL)"

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
#special pseudo-names
PRINTING_GROUP_SPECIALS := _CONV
#all known names
PRINTING_GROUP_ALL = $(PRINTING_GROUP_1) $(PRINTING_GROUP_2) $(PRINTING_GROUP_3)\
    $(PRINTING_GROUP_4) $(PRINTING_GROUP_5) $(PRINTING_GROUP_SPECIALS)

# tries to deduce proper description from <prog>, and use $@, $< and $^.
# for empty <prog>, prints 'Generating $@'
# for special prog _CONV, prints 'Converting $< to $@'
define PRINT_SMART_DESC #<prog>
	@#rules for defined groups are (descriptions above)
	@ $(if $(filter $(PRINTING_GROUP_1),$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_CXX),,$(1),compiling,$<))
	@ $(if $(filter $(PRINTING_GROUP_2),$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_CXX),,$(1),compiling,$@))
	@ $(if $(filter $(PRINTING_GROUP_3),$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_CP),,,Copying,$@,from,$<))
	@ $(if $(filter $(PRINTING_GROUP_4),$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_LD),,,Linking,$@))
	@ $(if $(filter $(PRINTING_GROUP_5),$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_CPRESS),,$(1),compressing,$@))
	@ $(if $(filter _CONV,$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_CONV),,,Converting,$<,to,$@))
	@# generic rule, for anything other (i.e. when <prog> is not empty)
	@ $(if $(filter-out "$(PRINTING_GROUP_ALL)",$(1)),$(call PRINT_CMD_DESCRIPTION,$(STYLE_GEN),,$(1),generating,$@),)
	@# generic rule, when <prog> is empty
	@ $(if $(1),,$(call PRINT_CMD_DESCRIPTION,$(STYLE_GEN),,,Generating,$@))
endef

#prints <desc> in STYLE_GNRIC style, optionally adding <fname> printed as filename
define PRINT_GENERIC_DESC #<desc> <fname>
	$(call PRINT_CMD_DESCRIPTION,$(STYLE_GNRIC),,,$(1),$(2))
endef
