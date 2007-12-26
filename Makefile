# these values filled in by    yorick -batch make.i
Y_MAKEDIR=/home/frigaut/yorick-2.1/Linux-i686
Y_EXE=/home/frigaut/yorick-2.1/Linux-i686/bin/yorick
Y_EXE_PKGS=
Y_EXE_HOME=/home/frigaut/yorick-2.1/Linux-i686
Y_EXE_SITE=/home/frigaut/yorick-2.1

# ----------------------------------------------------- optimization flags

# options for make command line, e.g.-   make COPT=-g TGT=exe
COPT=$(COPT_DEFAULT)
TGT=$(DEFAULT_TGT)

# ------------------------------------------------ macros for this package

PKG_NAME=spydr
PKG_I=mouse_nowait.i spydr.i

OBJS=mouse_nowait.o

# change to give the executable a name other than yorick
PKG_EXENAME=yorick

# PKG_DEPLIBS=-Lsomedir -lsomelib   for dependencies of this package
PKG_DEPLIBS=
# set compiler (or rarely loader) flags specific to this package
PKG_CFLAGS=
PKG_LDFLAGS=

# list of additional package names you want in PKG_EXENAME
# (typically Y_EXE_PKGS should be first here)
EXTRA_PKGS=$(Y_EXE_PKGS)

# list of additional files for clean
PKG_CLEAN=

# autoload file for this package, if any
PKG_I_START=spydr_start.i
# non-pkg.i include files for this package, if any
PKG_I_EXTRA=spydr_plugins.i spydr_psffit.i spydr_various.i

# -------------------------------- standard targets and rules (in Makepkg)

# set macros Makepkg uses in target and dependency names
# DLL_TARGETS, LIB_TARGETS, EXE_TARGETS
# are any additional targets (defined below) prerequisite to
# the plugin library, archive library, and executable, respectively
PKG_I_DEPS=$(PKG_I)
Y_DISTMAKE=distmake

include $(Y_MAKEDIR)/Make.cfg
include $(Y_MAKEDIR)/Makepkg
include $(Y_MAKEDIR)/Make$(TGT)

# override macros Makepkg sets for rules and other macros
# Y_HOME and Y_SITE in Make.cfg may not be correct (e.g.- relocatable)
Y_HOME=$(Y_EXE_HOME)
Y_SITE=$(Y_EXE_SITE)

# reduce chance of yorick-1.5 corrupting this Makefile
MAKE_TEMPLATE = protect-against-1.5

# ------------------------------------- targets and rules for this package

# simple example:
#myfunc.o: myapi.h
# more complex example (also consider using PKG_CFLAGS above):
#myfunc.o: myapi.h myfunc.c
#	$(CC) $(CPPFLAGS) $(CFLAGS) -DMY_SWITCH -o $@ -c myfunc.c

install::
	mkdir -p $(DEST_Y_SITE)/python
	mkdir -p $(DEST_Y_SITE)/glade
	mkdir -p $(DEST_Y_SITE)/g
	mkdir -p $(DEST_Y_SITE)/share/spydr
	mkdir -p $(DEST_Y_BINDIR)
	cp -p spydr.py $(DEST_Y_SITE)/python/
	cp -p spydr.glade $(DEST_Y_SITE)/glade/
	cp -p spydr*.gs $(DEST_Y_SITE)/g/
	cp -p spydr.conf $(DEST_Y_SITE)/share/spydr/
	cp -p spydr $(DEST_Y_BINDIR)/

uninstall::
	-rm $(DEST_Y_SITE)/python/spydr.py
	-rm $(DEST_Y_SITE)/glade/spydr.glade
	-rm $(DEST_Y_SITE)/g/spydr*.gs
	-rm -rf $(DEST_Y_SITE)/share/spydr
	-rm $(DEST_Y_BINDIR)/spydr

clean::
	rm -rf binaries

# -------------------------------------------------------- end of Makefile


# for the binary package production (add full path to lib*.a below):
PKG_DEPLIBS_STATIC=-lm 
PKG_ARCH = $(OSTYPE)-$(MACHTYPE)
# or linux or windows
PKG_VERSION = $(shell (awk '{if ($$1=="Version:") print $$2}' $(PKG_NAME).info))
# .info might not exist, in which case he line above will exit in error.

# packages or devel_pkgs:
PKG_DEST_URL = packages

package:
	$(MAKE)
	$(LD_DLL) -o $(PKG_NAME).so $(OBJS) ywrap.o $(PKG_DEPLIBS_STATIC) $(DLL_DEF)
	mkdir -p binaries/$(PKG_NAME)/dist/y_home/lib
	mkdir -p binaries/$(PKG_NAME)/dist/y_home/bin
	mkdir -p binaries/$(PKG_NAME)/dist/y_home/i-start
	mkdir -p binaries/$(PKG_NAME)/dist/y_site/i0
	mkdir -p binaries/$(PKG_NAME)/dist/y_site/i
	cp -p $(PKG_I) binaries/$(PKG_NAME)/dist/y_site/i0/
	cp -p $(PKG_I_EXTRA) binaries/$(PKG_NAME)/dist/y_site/i/
	cp -p $(PKG_NAME).so binaries/$(PKG_NAME)/dist/y_home/lib/
	cp -p spydr binaries/$(PKG_NAME)/dist/y_home/bin/
	if test -f "check.i"; then cp -p check.i binaries/$(PKG_NAME)/.; fi
	if test -n "$(PKG_I_START)"; then cp -p $(PKG_I_START) \
	  binaries/$(PKG_NAME)/dist/y_home/i-start/; fi
	cat $(PKG_NAME).info | sed -e 's/OS:/OS: $(PKG_ARCH)/' > tmp.info
	mv tmp.info binaries/$(PKG_NAME)/$(PKG_NAME).info
	cd binaries; tar zcvf $(PKG_NAME)-$(PKG_VERSION)-$(PKG_ARCH).tgz $(PKG_NAME)

distbin:
	if test -f "binaries/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_ARCH).tgz" ; then \
	  ncftpput -f $(HOME)/.ncftp/maumae www/yorick/$(PKG_DEST_URL)/$(PKG_ARCH)/tarballs/ \
	  binaries/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_ARCH).tgz; fi
	if test -f "binaries/$(PKG_NAME)/$(PKG_NAME).info" ; then \
	  ncftpput -f $(HOME)/.ncftp/maumae www/yorick/$(PKG_DEST_URL)/$(PKG_ARCH)/info/ \
	  binaries/$(PKG_NAME)/$(PKG_NAME).info; fi

distsrc:
	make clean; rm -rf binaries
	cd ..; tar --exclude binaries --exclude .svn -zcvf \
	   $(PKG_NAME)-$(PKG_VERSION)-src.tgz $(PKG_NAME);\
	ncftpput -f $(HOME)/.ncftp/maumae www/yorick/$(PKG_DEST_URL)/src/ \
	   $(PKG_NAME)-$(PKG_VERSION)-src.tgz


# -------------------------------------------------------- end of Makefile
