# Here are defined variables and functions for
# supressing superfluous make output and printing
# messages

# variable
ifdef VERBOSE_MAKE
HIDE :=
else
HIDE := @
endif

#check, if output is terminal
ifeq ($(shell (if [ -t 1 ] ; then printf 1; fi)),1)
# Colors for fancy output - we are in terminal
# In facts, these may be styles, no only colors
FPC_NONE := $(if ,\e[0m,)
FPC_FNAME := \e[0;1;32m
FPC_PROGNAME := \e[0;1;33m
FPC_CXX := \e[0;32m
FPC_CP := \e[0;32m
FPC_CONV := \e[0;33m
FPC_GEN := \e[0;34m
FPC_LD := \e[0;35m
FPC_RUN := \e[0;36m
FPC_GENERIC := \e[0;31m
FP_ENDL := \e[0m\n
else
# Color variables don't need to be defined, if we are not
# writing to terminal - they will behave as empty
FP_ENDL := \n
endif

#
# Functions for fancy output
#

# glossary:
# (to be extended)
#
# program, progname - name of program executed by make, e.g. g++, bison, mf
#

# not best way to do it, but works quite well:
# function returning path to file relative to source root
FP__FULL_FNAME = $(subst $(abspath $(depth))/,,$(abspath $(1)))
# function returning path to file, colored as filename
FPW__FNAME = $(FPC_FNAME)$(call FP__FULL_FNAME,$(1))
# function returning argument, colored as program name
FPW__PRGN = $(FPC_PROGNAME)$(1)

# prints "<desc0> <prog> <desc1> <fn1> <desc2> <fn2>", with
#   <prog>    as PROGNAME
#   <fn*>     as FNAME
#   <desc*>   as <style>
#
# All arguments may be empty.
define PRINT_GENERIC_DESC #<style>(1) <desc0>(2) <prog>(3) <desc1>(4) <fn1>(5) <desc2>(6) <fn2>(7)
    @ env echo -ne "$(if $(2),$(1)$(2) ,)$(if $(3),$(call FPW__PRGN,$(3)) ,)"\
        "$(if $(4),$(2)$(4) ,)$(if $(5),$(call FPW__FNAME,$(5)) ,)$(if $(6),$(2)$(6) ,)"\
        "$(if $(7),$(call FPW__FNAME,$(7)) ,)$(FP_ENDL)"
endef

# prints "<prog> <doing> <what>", with
#   <prog>    as PROGNAME
#   <doing>   as GENERIC
#   <what>    as FNAME
define FP_GENERIC_WITH #<prog> <doing> <what(file)>
    @ env echo -ne "$(call FPW__PRGN,$(1))$(FPC_GENERIC)$(2) $(call FPW__FNAME,$(3))$(FP_ENDL)"
endef

# prints "Compiling <what>", with
#   <what>    as FNAME
#   rest      as CXX
define FP_COMPILATION #<what>
    @ env echo -ne "$(FPC_CXX)Compiling $(call FPW__FNAME,$(1))$(FP_ENDL)"
endef

# prints "Compiling <what> into <target>", with
#   <what>    as FNAME
#   <target>  as FNAME
#   rest      as CXX
define FP_COMPILATION_TO #<what> <target>
    @ env echo -ne "$(FPC_CXX)Compiling $(call FPW__FNAME,$(1))$(FPC_CXX) into $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef

# prints "<prog> compiling <what>", with
#   <prog>    as PRGN
#   <what>    as FNAME
#   rest      as CXX
define FP_COMPILATION_WITH #<prog> <what>
    @ env echo -ne "$(call FPW__PRGN,$(1))$(FPC_CXX) compiling $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef

# prints "<prog> compiling <what> into <target>", with
#   <prog>    as PRGN
#   <what>    as FNAME
#   <target>  as FNAME
#   rest      as CXX
define FP_COMPILATION_WITH_TO #<prog> <what> <target>
    @ env echo -ne "$(call FPW__PRGN,$(1))$(FPC_CXX) compiling $(call FPW__FNAME,$(2))$(FPC_CXX) into $(call FPW__FNAME,$(3))$(FP_ENDL)"
endef

# prints "Copying <what>", with
#   <what>    as FNAME
#   rest      as CP
define FP_COPY #<what>
    @ env echo -ne "$(FPC_CP)Copying $(call FPW__FNAME,$(1))$(FP_ENDL)"
endef

# prints "Copying <what> to <target>", with
#   <what>    as FNAME
#   <target>  as FNAME
#   rest      as CP
define FP_COPY_TO #<what> <target>
    @ env echo -ne "$(FPC_CP)Copying $(call FPW__FNAME,$(1))$(FPC_CP) to $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef

# prints "Copying <what> from <source>", with
#   <what>    as FNAME
#   <source>  as FNAME
#   rest      as CP
define FP_COPY_FROM #<what> <source>
    @ env echo -ne "$(FPC_CP)Copying $(call FPW__FNAME,$(1))$(FPC_CP) from $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef

define FP_CONVERSION
    @ env echo -ne "$(FPC_CONV)Converting $(call FPW__FNAME,$(1))$(FP_ENDL)"
endef
define FP_CONVERSION_TO
    @ env echo -ne "$(FPC_CONV)Converting $(call FPW__FNAME,$(1))$(FPC_CONV) into $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef

define FP_GENERATION
    @ env echo -ne "$(FPC_GEN)Generating $(call FPW__FNAME,$(1))$(FP_ENDL)"
endef
define FP_GENERATION_WITH
    @ env echo -ne "$(call FPW__PRGN,$(1))$(FPC_GEN) generating $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef

define FP_LINKAGE
    @ env echo -ne "$(FPC_LD)Linking $(call FPW__FNAME,$(1))$(FP_ENDL)"
endef
define FP_LINKAGE_WITH
    @ env echo -ne "$(call FPW__PRGN,$(1))$(FPC_LD) linking $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef

define FP_RUNNING
    @ env echo -ne "$(FPC_RUN)Running $(call FPW__FNAME,$(1))$(FP_ENDL)"
endef

# Functions for fancy output - shortcuts

define FP_CXX
    $(call FP_COMPILATION_WITH,$(CXX),$(1))
endef
define FP_CXX_TO
    $(call FP_COMPILATION_WITH_TO,$(CXX),$(1),$(2))
endef

define FP_MF
    $(call FP_COMPILATION_WITH,METAFONT,$(1))
endef

define FP_LD
    $(call FP_LINKAGE_WITH,$(CXX),$(1))
endef
