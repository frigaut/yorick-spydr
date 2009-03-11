# these values filled in by    yorick -batch make.i
Y_MAKEDIR=/home/frigaut/yorick-2.1
Y_EXE=/home/frigaut/yorick-2.1/bin/yorick
Y_EXE_PKGS=
Y_EXE_HOME=/home/frigaut/yorick-2.1
Y_EXE_SITE=/home/frigaut/yorick-2.1

# 
# !! THIS IS NOT A PLUGIN !!
# This is a package made of several interpreted 
# include file. This makefile is just used to install,
# uninstall it or build the distribution tar file.

# ------------------------------------------------ macros for this package

# used for distribution
PKG_NAME = spydr
# include files for this package
PKG_I=spydr.i spydr_plugins.i spydr_psffit.i spydr_various.i spydr_pyk.i
# autoload file for this package, if any
PKG_I_START=spydr_start.i

# override macros Makepkg sets for rules and other macros
# Y_HOME and Y_SITE in Make.cfg may not be correct (e.g.- relocatable)
Y_HOME=$(Y_EXE_HOME)
Y_SITE=$(Y_EXE_SITE)

DEST_Y_SITE=$(DESTDIR)$(Y_SITE)
DEST_Y_HOME=$(DESTDIR)$(Y_HOME)
DEST_Y_BINDIR=$(DEST_Y_HOME)/bin

# ------------------------------------- targets and rules for this package

build:
	@echo "Nothing to build. This is not a plugin"
	@echo "other targets: install, uninstall, clean"
	@echo "for maintainers: package, distpkg"

clean::
	-rm -rf pkg

install::
	mkdir -p $(DEST_Y_SITE)/python
	mkdir -p $(DEST_Y_SITE)/glade
	mkdir -p $(DEST_Y_SITE)/g
	mkdir -p $(DEST_Y_SITE)/gist
	mkdir -p $(DEST_Y_SITE)/share/spydr
	mkdir -p $(DEST_Y_BINDIR)
	cp -p $(PKG_I) $(DEST_Y_SITE)/i/
	cp -p spydr.py $(DEST_Y_SITE)/python/
	cp -p spydr.glade $(DEST_Y_SITE)/glade/
	cp -p spydr*.gs $(DEST_Y_SITE)/g/
	cp -p spydr*.gs $(DEST_Y_SITE)/gist/
	cp -p spydr.conf $(DEST_Y_SITE)/share/spydr/
	cp -p LICENSE $(DEST_Y_SITE)/share/spydr/
	cp -p README $(DEST_Y_SITE)/share/spydr/
	cp -p test3.fits $(DEST_Y_SITE)/share/spydr/
	cp -p spydr $(DEST_Y_BINDIR)/

uninstall::
	-cd $(DEST_Y_SITE)/i; rm $(PKG_I) 
	-rm $(DEST_Y_SITE)/python/spydr.py
	-rm $(DEST_Y_SITE)/glade/spydr.glade
	-rm $(DEST_Y_SITE)/g/spydr*.gs
	-rm $(DEST_Y_SITE)/gist/spydr*.gs
	-rm -rf $(DEST_Y_SITE)/share/spydr
	-rm $(DEST_Y_BINDIR)/spydr

# -------------------------------------------- package build rules


PKG_VERSION = $(shell (awk '{if ($$1=="Version:") print $$2}' $(PKG_NAME).info))
# .info might not exist, in which case he line above will exit in error.

# packages or devel_pkgs:
PKG_DEST_URL = packages

package:
	mkdir -p pkg/$(PKG_NAME)/dist/y_site/i
	mkdir -p pkg/$(PKG_NAME)/dist/y_site/python
	mkdir -p pkg/$(PKG_NAME)/dist/y_site/glade
	mkdir -p pkg/$(PKG_NAME)/dist/y_site/g
	mkdir -p pkg/$(PKG_NAME)/dist/y_site/gist
	mkdir -p pkg/$(PKG_NAME)/dist/y_home/i-start
	mkdir -p pkg/$(PKG_NAME)/dist/y_site/share/spydr
	mkdir -p pkg/$(PKG_NAME)/dist/y_home/bin

	cp -p $(PKG_I) pkg/$(PKG_NAME)/dist/y_site/i/
	cp -p spydr.py pkg/$(PKG_NAME)/dist/y_site/python/
	cp -p spydr.glade pkg/$(PKG_NAME)/dist/y_site/glade/
	cp -p *.gs pkg/$(PKG_NAME)/dist/y_site/g/
	cp -p *.gs pkg/$(PKG_NAME)/dist/y_site/gist/
	cp -p spydr.conf pkg/$(PKG_NAME)/dist/y_site/share/spydr/
	cp -p LICENSE pkg/$(PKG_NAME)/dist/y_site/share/spydr/
	cp -p README pkg/$(PKG_NAME)/dist/y_site/share/spydr/
	cp -p test3.fits pkg/$(PKG_NAME)/dist/y_site/share/spydr/
	cp -p spydr pkg/$(PKG_NAME)/dist/y_home/bin/
	cd pkg/$(PKG_NAME)/dist/y_site/i/; if test -f "check.i"; then rm check.i; fi
	if test -f "check.i"; then cp -p check.i pkg/$(PKG_NAME)/.; fi
	if test -n "$(PKG_I_START)"; then cp -p $(PKG_I_START) \
	  pkg/$(PKG_NAME)/dist/y_home/i-start/; fi
	cp -p $(PKG_NAME).info pkg/$(PKG_NAME)/$(PKG_NAME).info
	cd pkg; tar zcvf $(PKG_NAME)-$(PKG_VERSION)-pkg.tgz $(PKG_NAME)

distbin: package
#tarball there
	if test -f "pkg/$(PKG_NAME)-$(PKG_VERSION)-pkg.tgz" ; then \
	  ncftpput -f $(HOME)/.ncftp/maumae www/yorick/packages/tarballs/ \
	  pkg/$(PKG_NAME)-$(PKG_VERSION)-pkg.tgz; fi
#info files in each architecture directory
	if test -f "pkg/$(PKG_NAME)/$(PKG_NAME).info" ; then \
		ncftpput -f $(HOME)/.ncftp/maumae www/yorick/packages/darwin-ppc/info/ \
		pkg/$(PKG_NAME)/$(PKG_NAME).info; fi
	if test -f "pkg/$(PKG_NAME)/$(PKG_NAME).info" ; then \
		ncftpput -f $(HOME)/.ncftp/maumae www/yorick/packages/darwin-i386/info/ \
		pkg/$(PKG_NAME)/$(PKG_NAME).info; fi
	if test -f "pkg/$(PKG_NAME)/$(PKG_NAME).info" ; then \
		ncftpput -f $(HOME)/.ncftp/maumae www/yorick/packages/linux-ppc/info/ \
		pkg/$(PKG_NAME)/$(PKG_NAME).info; fi
	if test -f "pkg/$(PKG_NAME)/$(PKG_NAME).info" ; then \
		ncftpput -f $(HOME)/.ncftp/maumae www/yorick/packages/linux-x86/info/ \
		pkg/$(PKG_NAME)/$(PKG_NAME).info; fi

distsrc:
	make clean; rm -rf pkg
	cd ..; tar --exclude pkg --exclude .svn --exclude CVS --exclude *.spec -zcvf \
	   $(PKG_NAME)-$(PKG_VERSION)-src.tgz yorick-$(PKG_NAME)-$(PKG_VERSION);\
	ncftpput -f $(HOME)/.ncftp/maumae www/yorick/packages/src/ \
	   $(PKG_NAME)-$(PKG_VERSION)-src.tgz
	ncftpput -f $(HOME)/.ncftp/maumae www/yorick/contrib/ \
	   ../$(PKG_NAME)-$(PKG_VERSION)-src.tgz


# -------------------------------------------------------- end of Makefile
