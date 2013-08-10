# make/Stepmake.make

# If usescons=something then reroute to scons if user is using that.
ifdef usescons

SCONS_USER = $(wildcard $(depth)/.sconsign)
ifeq ($(SCONS_USER),)
SCONS_USER = $(wildcard $(depth)/.sconf_temp)
endif
ifneq ($(SCONS_USER),)

ifeq ($(strip $(depth)),..)
here = $(notdir $(CURDIR))
else
ifeq ($(strip $(depth)),../..)
# ZUCHT?
# here = $(notdir $(dir $(CURDIR)))/$(notdir $(CURDIR))
here = $(shell basename $$(dirname $(CURDIR)))/$(notdir $(CURDIR))
endif
endif

MAKE_TARGETS = config deb diff dist distclean doc release po		\
po-replace po-update all clean check default exe help install lib web	\
web-install web-clean TAGS

$(MAKE_TARGETS): scons

# To make this trickery complete, we could have ./configure remove
# traces of scons configuration.
scons:
	@echo "warning: $(SCONS_USER) detected, rerouting to scons"
	cd $(depth) && scons $(here) $(MAKECMDGOALS)
	false
endif
endif


# Use alternate configurations alongside eachother:
#
#     ./configure --enable-config=debug
#     make conf=debug
#
# uses config-debug.make and config-debug.h; output goes to out-debug.
#
ifdef conf
  CONFIGSUFFIX=-$(conf)
endif

# Use same configuration, but different output directory:
#
#     make out=www
#
# uses config.make and config.h; output goes to out-www.
#
ifdef out
  outbase=out-$(out)
else
  outbase=out$(CONFIGSUFFIX)
endif

ifdef config
  config_make=$(config)
else
  config_make=$(depth)/config$(CONFIGSUFFIX).make
endif

outroot=.

include $(config_make)

include $(depth)/make/toplevel-version.make

#
# suggested settings
#
# CPU_COUNT=2   ## for SMP/Multicore machine
# 
-include $(depth)/local.make

MICRO_VERSION=$(PATCH_LEVEL)
BUILD_VERSION=1


outdir=$(outroot)/$(outbase)

# why not generic ??
config_h=$(top-build-dir)/config$(CONFIGSUFFIX).hh

# The outdir that was configured for: best guess to find binaries
outconfbase=out$(CONFIGSUFFIX)
outconfdir=$(outroot)/$(outconfbase)

# user package
stepdir = $(stepmake)/stepmake
# for stepmake package
# stepdir = $(depth)/stepmake

STEPMAKE_TEMPLATES := generic $(STEPMAKE_TEMPLATES)
LOCALSTEPMAKE_TEMPLATES:= generic $(LOCALSTEPMAKE_TEMPLATES)

# Don't try to outsmart us, you puny computer!
# Well, UGH.  This only removes builtin rules from
# subsequent $(MAKE)s, *not* from the current run!
ifeq ($(BUILTINS_REMOVED),)
  export BUILTINS_REMOVED = yes
  MAKE:=$(MAKE) --no-builtin-rules
  include $(stepdir)/no-builtin-rules.make
endif
.SUFFIXES:

# Keep this empty to prevent make from removing intermediate files.
.SECONDARY:

# Colors for fancy output
FP_C__NONE := \e[0m
FP_C__FNAME := \e[0;1;32m
FP_C__PROGNAME := \e[0;1;33m
FP_C__STD_CXX := \e[0;32m
FP_C__STD_CP := \e[0;32m
FP_C__STD_CONV := \e[0;33m
FP_C__STD_GEN := \e[0;34m
FP_C__STD_LD := \e[0;35m
FP_C__STD_RUN := \e[0;36m
FP_C__STD_GENERIC := \e[0;31m

FP_ENDL := \e[0m\n

#
# Functions for fancy output
#

#not best option, but works quite well
FP__FULL_FNAME = $(subst $(abspath $(depth))/,,$(abspath $(1)))
FPW__FNAME = $(FP_C__FNAME)$(call FP__FULL_FNAME,$(1))
FPW__PRGN = $(FP_C__PROGNAME)$(1)

define FANCY_PRINT_GENERIC #<prog> <doing>
	@ env echo -ne "$(FP_C__STD_GENERIC)$(1) $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef
define FANCY_PRINT_GENERIC_WITH #<prog> <doing> <what(file)>
	@ env echo -ne "$(call FPW__PRGN,$(1))$(FP_C__STD_GENERIC)$(2) $(call FPW__FNAME,$(3))$(FP_ENDL)"
endef

define FANCY_PRINT_COMPILATION
	@ env echo -ne "$(FP_C__STD_CXX)Compiling $(call FPW__FNAME,$(1))$(FP_ENDL)"
endef
define FANCY_PRINT_COMPILATION_TO
	@ env echo -ne "$(FP_C__STD_CXX)Compiling $(call FPW__FNAME,$(1))$(FP_C__STD_CXX) into $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef
define FANCY_PRINT_COMPILATION_WITH
	@ env echo -ne "$(call FPW__PRGN,$(1))$(FP_C__STD_CXX) compiling $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef
define FANCY_PRINT_COMPILATION_WITH_TO
	@ env echo -ne "$(call FPW__PRGN,$(1))$(FP_C__STD_CXX) compiling $(call FPW__FNAME,$(2))$(FP_C__STD_CXX) into $(call FPW__FNAME,$(3))$(FP_ENDL)"
endef

define FANCY_PRINT_COPY
	@ env echo -ne "$(FP_C__STD_CP)Copying $(call FPW__FNAME,$(1))$(FP_ENDL)"
endef
define FANCY_PRINT_COPY_TO
	@ env echo -ne "$(FP_C__STD_CP)Compiling $(call FPW__FNAME,$(1))$(FP_C__STD_CP) to $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef
define FANCY_PRINT_COPY_FROM
	@ env echo -ne "$(FP_C__STD_CP)Compiling $(call FPW__FNAME,$(1))$(FP_C__STD_CP) from $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef

define FANCY_PRINT_CONVERSION
	@ env echo -ne "$(FP_C__STD_CONV)Converting $(call FPW__FNAME,$(1))$(FP_ENDL)"
endef
define FANCY_PRINT_COMPILATION_TO
	@ env echo -ne "$(FP_C__STD_CONV)Converting $(call FPW__FNAME,$(1))$(FP_C__STD_CONV) into $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef

define FANCY_PRINT_GENERATION
	@ env echo -ne "$(FP_C__STD_GEN)Generating $(call FPW__FNAME,$(1))$(FP_ENDL)"
endef
define FANCY_PRINT_GENERATION_WITH
	@ env echo -ne "$(call FPW__PRGN,$(1))$(FP_C__STD_GEN) generating $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef

define FANCY_PRINT_LINKAGE
	@ env echo -ne "$(FP_C__STD_LD)Linking $(call FPW__FNAME,$(1))$(FP_ENDL)"
endef
define FANCY_PRINT_LINKAGE_WITH
	@ env echo -ne "$(call FPW__PRGN,$(1))$(FP_C__STD_LD) linking $(call FPW__FNAME,$(2))$(FP_ENDL)"
endef

define FANCY_PRINT_RUNNING
	@ env echo -ne "$(FP_C__STD_RUN)Running $(call FPW__FNAME,$(1))$(FP_ENDL)"
endef

# Functions for fancy output - shortcuts

define FANCY_PRINT_CXX
	$(call FANCY_PRINT_COMPILATION_WITH,$(CXX),$(1))
endef
define FANCY_PRINT_CXX_TO
	$(call FANCY_PRINT_COMPILATION_WITH_TO,$(CXX),$(1),$(2))
endef

define FANCY_PRINT_MF
	$(call FANCY_PRINT_COMPILATION_WITH,METAFONT,$(1))
endef

define FANCY_PRINT_LD
	$(call FANCY_PRINT_LINKAGE_WITH,$(CXX),$(1))
endef

all:

-include $(addprefix $(depth)/make/,$(addsuffix -inclusions.make, $(LOCALSTEPMAKE_TEMPLATES)))

-include $(addprefix $(stepdir)/,$(addsuffix -inclusions.make, $(STEPMAKE_TEMPLATES)))


include $(addprefix $(stepdir)/,$(addsuffix -vars.make, $(STEPMAKE_TEMPLATES)))

# ugh. need to do this because of PATH :=$(top-src-dir)/..:$(PATH)
include $(addprefix $(depth)/make/,$(addsuffix -vars.make, $(LOCALSTEPMAKE_TEMPLATES)))


include $(addprefix $(depth)/make/,$(addsuffix -rules.make, $(LOCALSTEPMAKE_TEMPLATES)))
include $(addprefix $(stepdir)/,$(addsuffix -rules.make, $(STEPMAKE_TEMPLATES)))
include $(addprefix $(depth)/make/,$(addsuffix -targets.make, $(LOCALSTEPMAKE_TEMPLATES)))
include $(addprefix $(stepdir)/,$(addsuffix -targets.make, $(STEPMAKE_TEMPLATES)))
