#
# project  LilyPond -- the musical typesetter
# title	   generic variables
# file	   make/Variables.make
# abstract do not change this file; edit settings in User.make
#
# Copyright (c) 1997 by    
#   	Jan Nieuwenhuizen <jan@digicash.com>
#	Han-Wen Nienhuys <hanwen@stack.nl>

# toplevel version info, might be handy?
#
include ./$(depth)/.version
#

# directory names:
#
outdir = out# "objects" won-t do, used for libs and deps as well
bindir = ./$(depth)/bin
distdir = ./$(depth)/$(DIST_NAME)
module-distdir = ./$(depth)/$(MODULE_DIST_NAME)
depdir = $(outdir)
libdir = $(outdir)
flowerout = ./$(depth)/flower/lib/$(outdir)
libout = ./$(depth)/lib/$(outdir)
# flower-dir = ./$(depth)/flower
include-lib = ./$(depth)/lib/include
include-flower = ./$(depth)/flower/lib/include
#

# user settings:
#
include ./$(depth)/make/User.make
#

ifdef PROFILEFLAG
	DEFINES+=$(OPTIFLAG) $(PROFILEFLAG)
	EXTRA_LIBES+=-pg
endif

ifndef DEBUGFLAG
	DEFINES+=$(OPTIFLAG)
else
	DEFINES+=$(DEBUGFLAG)
endif

# build no:
#
# need to be defined in local Makefiles:
# build = ./$(depth)/lily/.build
BUILD = $(shell cat $(build))
INCREASE_BUILD = @echo `expr \`cat $(build)\` + 1` > .b; mv .b $(build)
#

# the version:
#
VERSION=$(MAJOR_VERSION).$(MINOR_VERSION).$(PATCH_LEVEL)$(MY_PATCH_LEVEL)
TOPLEVEL_VERSION=$(TOPLEVEL_MAJOR_VERSION).$(TOPLEVEL_MINOR_VERSION).$(TOPLEVEL_PATCH_LEVEL)$(TOPLEVEL_MY_PATCH_LEVEL)
#

# compiler version:
#
CXXVER=`$(CXX) --version`
#

# module and top level dist:
#
# fix naming, use TOPLEVEL_ prefix _or_ MODULE?
MODULE_DIST_NAME = $(MODULE_NAME)-$(VERSION)
DIST_NAME = lilypond-$(TOPLEVEL_VERSION)
#

# list of object files:
#
SOURCE_FILES = $(CCFILES) $(EXTRA_SOURCE_FILES)
OFILEC = $(SOURCE_FILES:.c=.o)
OFILECC = $(OFILEC:.cc=.o)
OFILEL = $(OFILECC:.l=.o)
OFILEY = $(OFILEL:.y=.o)
OFILES = $(patsubst %,$(outdir)/%,$(OFILEY))
#

# clean file lists:
#
allexe = $(bindir)/lilypond $(bindir)/m2m
allobs = $(shell find $(outdir) -name "*.o" )
allibs = $(shell find $(libdir) -name "*.lib" )
alldeps = $(shell find $(outdir) -name "*.dep" )
allout = $(shell find . -name "$(outdir)" )
#

# version stuff:
#
flower-version = $(flowerout)/fversion.hh
lily-version = $(libout)/version.hh
#

# custom libraries:
#
LIBFLOWER = $(depth)/flower/lib/$(outdir)/$(LIB_PREFIX)flower$(LIB_SUFFIX)
LIBLILY = $(depth)/lib/$(outdir)/$(LIB_PREFIX)lily$(LIB_SUFFIX)
#

# compile and link options:
#
ARFLAGS = ru
CFLAGS = $(DEFINES) $(INCLUDES) $(USER_CFLAGS) $(EXTRA_CFLAGS)
CXXFLAGS = $(CFLAGS) $(USER_CXXFLAGS) $(EXTRA_CXXFLAGS)
INCLUDES = -Iinclude -I$(outdir) -I$(include-lib) -I$(libout) -I$(include-flower) -I$(flowerout) 
CXX_OUTPUT_OPTION = $< -o $@
LDFLAGS = $(EXTRA_LDFLAGS)
LOADLIBES = $(EXTRA_LIBES) $(CUSTOMLIBES) -lg++
#

# librarian:
#
AR = ar
AR_COMMAND = $(AR) $(ARFLAGS) $@
#

# compiler:
#
# "CC = $(CC)"
# "CXX = $(CXX)"
#

# linker:
#
LD = $(CXX)
LD_COMMAND = $(LD) $(LDFLAGS) -o $@
#

# dependencies:
#
depfile = ./$(depdir)/$(subst .o,.dep,$(notdir $@)) 
DODEP=rm -f $(depfile); DEPENDENCIES_OUTPUT="$(depfile) $(outdir)/$(notdir $@)"
#

# utils:
#
FLEX = flex
BISON = bison
#

# generic target names:
#
EXECUTABLE = $(NAME)$(EXE)
LIB_PREFIX = lib
LIB_SUFFIX = .a
LIBRARY = $(LIB_PREFIX)$(NAME)$(LIB_SUFFIX)
#

STRIPDEBUG=true #replace to do stripping of certain objects

