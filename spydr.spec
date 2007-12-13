%define name spydr
%define version 0.5.0
%define release gemini2007dec07

Summary: GUI for image display in yorick
Name: %{name}
Version: %{version}
Release: %{release}
Source0: %{name}-%{version}.tar.bz2
License: BSD
Group: Applications/Engineering
Packager: Francois Rigaut <frigaut@gemini.edu>
Url: http://www.maumae.net/yorick/doc/plugins.php
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
Requires: yorick >= 2.1 yorick-yao yorick-imutil >= 0.5 yorick-yutils >= 1.0 yorick-usleep


%description
Software Package in Yorick for Data Reduction.

Display image[s] and provide some basic analysis funcitonalities:
  * change color ITT and LUT, image level cuts
  * cut through images
  * zoom, unzoom
  * plot histogram
  * fit 1D gaussian to a profile
  * find Strehl and FWHM of an image
  * ...

help,spydr from the yorick prompt for more information

%prep
%setup -q

%build
yorick -batch make.i
make
if [ -f check.i ] ; then
   mv check.i %{name}_check.i
fi;

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/usr/lib/yorick/lib
mkdir -p $RPM_BUILD_ROOT/usr/lib/yorick/i0
mkdir -p $RPM_BUILD_ROOT/usr/lib/yorick/g
mkdir -p $RPM_BUILD_ROOT/usr/lib/yorick/glade
mkdir -p $RPM_BUILD_ROOT/usr/lib/yorick/python
mkdir -p $RPM_BUILD_ROOT/usr/bin
mkdir -p $RPM_BUILD_ROOT/usr/share/spydr
mkdir -p $RPM_BUILD_ROOT/etc

install -m 755 mouse_nowait.so $RPM_BUILD_ROOT/usr/lib/yorick/lib
install -m 755 spydr.py $RPM_BUILD_ROOT/usr/lib/yorick/python
install -m 755 spydr $RPM_BUILD_ROOT/usr/bin
install -m 644 *.i $RPM_BUILD_ROOT/usr/lib/yorick/i0
install -m 644 *.gs $RPM_BUILD_ROOT/usr/lib/yorick/g
install -m 644 spydr.glade $RPM_BUILD_ROOT/usr/lib/yorick/glade
install -m 644 spydr.conf $RPM_BUILD_ROOT/etc
install -m 644 test*.fits $RPM_BUILD_ROOT/usr/share/spydr

rm $RPM_BUILD_ROOT/usr/lib/yorick/i0/*_start.i

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
/usr/lib/yorick/lib/mouse_nowait.so
/usr/lib/yorick/python/spydr.py
/usr/bin/spydr
/usr/lib/yorick/i0/*.i
/usr/lib/yorick/g/*.gs
/usr/lib/yorick/glade/spydr.glade
/etc/spydr.conf
/usr/share/spydr/test*.fits


%changelog
