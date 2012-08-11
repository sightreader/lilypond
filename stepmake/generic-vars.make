top-build-dir = $(shell cd $(depth) && pwd)
build-dir = $(shell cd . && pwd)
tree-dir = $(subst $(top-build-dir),,$(build-dir))

absdir = $(shell cd $(1) ; pwd)


ifneq ($(configure-srcdir),.)
srcdir-build = 1
endif

ifndef srcdir-build
src-depth = $(depth)
else
src-depth = $(configure-srcdir)
endif

top-src-dir := $(shell cd $(src-depth); pwd)

ifndef srcdir-build
src-dir = .
else
src-dir = $(top-src-dir)$(tree-dir)
VPATH = $(src-dir)
endif

abs-src-dir = $(top-src-dir)$(tree-dir)

.UNEXPORT: build-dir src-dir tree-dir

src-wildcard = $(subst $(src-dir)/,,$(wildcard $(src-dir)/$(1)))

ifeq ($(distdir),)
  distdir = $(top-build-dir)/$(outdir)/$(DIST_NAME)
  DIST_NAME = $(package)-$(TOPLEVEL_VERSION)
endif
distname = $(package)-$(TOPLEVEL_VERSION)

doc-dir = $(src-depth)/Documentation
po-srcdir = $(src-depth)/po
po-outdir = $(depth)/po/$(outdir)

INSTALLPY=$(buildscript-dir)/install -c
INSTALL=$(INSTALLPY)

package-icon = $(outdir)/$(package)-icon.xpm

ifneq ($(strip $(MY_PATCH_LEVEL)),)
VERSION=$(MAJOR_VERSION).$(MINOR_VERSION).$(PATCH_LEVEL).$(MY_PATCH_LEVEL)
else
VERSION=$(MAJOR_VERSION).$(MINOR_VERSION).$(PATCH_LEVEL)
endif

ifneq ($(strip $(TOPLEVEL_MY_PATCH_LEVEL)),)
TOPLEVEL_VERSION=$(TOPLEVEL_MAJOR_VERSION).$(TOPLEVEL_MINOR_VERSION).$(TOPLEVEL_PATCH_LEVEL).$(TOPLEVEL_MY_PATCH_LEVEL)
else
TOPLEVEL_VERSION=$(TOPLEVEL_MAJOR_VERSION).$(TOPLEVEL_MINOR_VERSION).$(TOPLEVEL_PATCH_LEVEL)
endif


# no locale settings in the build process.
LANG=
export LANG


INFO_DIRECTORIES = Documentation

# clean file lists:
#
ERROR_LOG = 2> /dev/null
SILENT_LOG = 2>&1 > /dev/null

INCLUDES = $(src-dir)/include $(outdir) $($(PACKAGE)_INCLUDES) $(MODULE_INCLUDES)

M4 = m4

LOOP=+$(foreach i, $(SUBDIRS), $(MAKE) PACKAGE=$(PACKAGE) package=$(package) -C $(i) $@ &&) true

ETAGS_FLAGS =
CTAGS_FLAGS =

ifeq (cygwin,$(findstring cygwin,$(HOST_ARCH)))
CYGWIN_BUILD = yes
endif

ifeq (mingw,$(findstring mingw,$(HOST_ARCH)))
MINGW_BUILD = yes
endif

ifeq (darwin,$(findstring darwin,$(HOST_ARCH)))
DARWIN_BUILD = yes
endif

buildscript-dir = $(top-build-dir)/scripts/build/$(outconfbase)
auxpython-dir = $(src-depth)/python/auxiliar
auxscript-dir = $(src-depth)/scripts/auxiliar
script-dir = $(src-depth)/scripts
input-dir = $(src-depth)/input

flower-dir = $(src-depth)/flower
lily-dir = $(src-depth)/lily
include-flower = $(src-depth)/flower/include

export PYTHONPATH:=$(auxpython-dir):$(PYTHONPATH)

LILYPOND_INCLUDES = $(include-flower) $(depth)/flower/$(outdir)

# installed by 'make installextradoc'
EXTRA_DOC_FILES = \
  ANNOUNCEMENT ANNOUNCE-0.1 AUTHORS.txt  COPYING DEDICATION INSTALL.txt NEWS PATCHES.txt README.txt TODO \
  Documentation/out/*.txt\
  Documentation/tex/*.doc\
  Documentation/tex/*.bib\
  Documentation/logo/out/lelie_logo.gif\
  input\

INSTALLED_EXTRA_DOC_FILES = $(addprefix $(prefix:/%=%)/doc/lilypond/, $(EXTRA_DOC_FILES))


INSTALLED_DIST_FILES = $(addprefix $(prefix:/%=%)/, $(INSTALL_DIST_FILES))
