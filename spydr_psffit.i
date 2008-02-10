/*
 * spydr_psffit.i
 * 
 * PSF fitting functions for spydr. Computes Strehl ratio and FWHM.
 *
 * This file is part of spydr, an image viewer/data analysis tool
 *
 * $Id: spydr_psffit.i,v 1.9 2008-02-10 15:08:07 frigaut Exp $
 *
 * Copyright (c) 2007, Francois Rigaut
 *
 * This program is free software; you can redistribute it and/or  modify it
 * under the terms of the GNU General Public License  as  published  by the
 * Free Software Foundation; either version 3 of the License,  or  (at your
 * option) any later version.
 *
 * This program is distributed in the hope  that  it  will  be  useful, but
 * WITHOUT  ANY   WARRANTY;   without   even   the   implied   warranty  of
 * MERCHANTABILITY or  FITNESS  FOR  A  PARTICULAR  PURPOSE.   See  the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * $Log: spydr_psffit.i,v $
 * Revision 1.9  2008-02-10 15:08:07  frigaut
 * Version 0.7.6:
 * - can now change the dpi on the fly. ctrl++ and ctrl+- will enlarge
 *   or shrink the graphical areas. long time missing in yorick.
 *   I have tried to make the window resizable, but it's a mess. Not
 *   only in the management of events, but also in the policy: really,
 *   only enlarging proportionally makes sense.
 * - changed a bit the zoom behavior: now zoom is started once (the first
 *   time the mouse enter drawingarea1), and does not stop from that point.
 *   This is not ideal/economical (although disp_zoom returns immediately
 *   if the mouse is not in the image window), but it has the advantage
 *   of being sure the disp_zoom process does not spawn multiple instances
 *   (recurrent issue with "after").
 * - The menu items in the left menu bar are hidden/shown according to the
 *   window size.
 * - gotten rid of a few (unused) functions in spydr.i (the progressbar
 *   and message functions) that were conflicting with other pyk instances.
 * - there's now focus in and out functions that will reset the current
 *   window to what it was before the focus was given to spydr. This is
 *   convenient when one just want to popup a spydr window to look at an
 *   image, and then come back to whatever one was doing without having to
 *   execute a window,n command.
 * - fixed a bug in disp_cpc. Now, when a "e"/"E" command is executed
 *   while a subimage is displayed, the "e"/"E" applies to the displayed
 *   subimage, not the whole image.
 * - changed a bit the behavior of the lower graphical area: not the y
 *   range is the same as the image zcuts (cmin/cmax).
 * - fixed a small bug in get_subim (using floor/ceil instead of round
 *   for the indices determination).
 * - added "compact" keyword to the spydr function (when called from
 *   within yorick).
 * - clipping dpi values to [30,400].
 * - spydr.py: went for a self autodic instead of an explicit
 *   declaration of all functions.
 * - implemented smoothing by x2
 * - implemented 1d linear fitting
 *
 * Revision 1.8  2008/02/02 05:12:05  frigaut
 * fixed bug when picking star for fitting while being in "graphical axis
 * in arcsec" mode.
 *
 * Revision 1.7  2008/01/30 05:28:19  frigaut
 * - added spydr_pyk to avoid conflicts with other calls of pyk, and modify
 * spydr_pyk for our purpose. I know this means we will not benefit from
 * future pyk code improvements, but I can deal with that.
 * - added check of yorick main version to avoid use with V<2.1.05 (in which
 * current_mouse does not exist)
 *
 * Revision 1.6  2008/01/25 03:03:49  frigaut
 * - updated license or license text to GPLv3 in all files
 *
 * Revision 1.5  2008/01/24 15:05:17  frigaut
 * - added "delete from stack" feature
 * - some bugfix in psffit
 *
 * Revision 1.4  2008/01/23 21:11:22  frigaut
 * - load of new things:
 *
 * New Features:
 * - added a number of command line flags (see man page or spydr -h)
 * - can now handle series of image of different sizes
 * - can mix single image and cube
 * - cmin and cmax are now set per image (sticky setting)
 * - image titles are better handled
 * - updated man page
 * - new image can be opened from the GUI menu (filechooser, multiple
 *   selection ok)
 * - migrated to a spydrs structure, replaced many different variables, cleaner.
 * - now opens the GUI even with no image argument (can use "open" from menu)
 * - all errors are now also displayed as popups (critical quits yorick
 *   when called from shell)
 * - because some (of the more critical) errors can happen before python is
 *   started, I had to use zenity for the popup window. New dependency.
 * - added an "append" keyword to spydr. If set, the new image is appended
 *   to the list of displayed image. The old ones are kept, and the total
 *   number of image is ++
 * - append is also available from the GUI menu
 * - any action on displayed image can be null by using "help->refresh
 *   display" (in particular, sigmafilter)
 * - created "about" dialog.
 * - added an "image" menu (with names of all images in stack). user can
 *   select image form there.
 * - added an "ops" (operation) menu. Can compute median, average, sum and
 *   rms of cube.
 * - small gui (without lower panel) form is called with --compact (-c)
 *
 * Bug fixes:
 * - fixed path to find python and glade files
 * - fixed path for configuration file
 * - main routine re-written and much more robust and clean
 * - (kind of) solved a issue where image got displayed several times
 *   because of echo from setting cmin and cmax
 * - fixed thibaut bug when closing window.
 * - fixed "called_from_shell" when no image argument.
 * - waiting for a doc for the user buttons, set to insivible.
 * - waiting for a proper implementation of find, pane set to invisible.
 *
 *
 * - bug: sometimes the next/previous image does not register
 *
 * Revision 1.3  2008/01/17 13:15:17  frigaut
 * - modified the name of lmfit (-> spydr_lmfit) in spydr_psffit to avoid
 * conflicts with the lmfit of yutils.
 * - modified all calls of lmfit -> spydr_lmfit (spydr_psffit and spydr_various)
 * - also default box size is now 51 (was 181)
 *
 * Revision 1.2  2007/12/13 13:43:27  frigaut
 * - added license headers in all files
 * - added LICENSE
 * - slightly modified Makefile
 * - updated info
 * - bumped to 0.5.1
 *
 *
 *
 */


version = "1.5";
modifDate = "June 17, 2007";

require,"random.i";
require,"string.i";
require,"random_et.i";
require,"utils.i";
require,"spydr_various.i";
require,"astro_util1.i"; // for sky()
require,"aoutil.i"; // for fwhmStrehl()

struct s_yfwhmres { double xpos, xposerr, ypos, yposerr, pstrehl, pfwhm, xfwhm, xfwhmerr, yfwhm, yfwhmerr, flux, fluxerr, el, elerr, angle, maxim, background;};

func parseDate(strdate)
{
  y=m=d=0;
  sread,strdate,format="%4d-%2d-%2d",y,m,d;
  return [y,m,d];
}
func parseTime(strtime)
{
  h=m=0; s=0.;
  sread,strtime,format="%2d:%2d:%f",h,m,s;
  return h+m/60.+s/3600.;
}

func getam(hdr,verbose=)
/* DOCUMENT func getam(hdr,verbose=)
   Determine airmass from the information available in the AC header
   for use in yfwhm.i procedure.
   SEE ALSO:
*/
{
  // Find the observing location (GN or GS?):
  loc	= strtrim(sxpar(hdr,"OBSERVAT"));
  if (loc == "Gemini-North") {
    longitude= -1*[155,28.3]; // At MK
    latitude= [19,49.6];
    if (is_set(verbose)) {print,"Found Location : Gemini-North";}
  } else if (loc == "Gemini-South") {
    longitude= -1*[70,43.4];  // At Pachon
    latitude= -1*[30,13.7];
    if (is_set(verbose)) {print,"Found Location : Gemini-South";}
  } else {
    exit,"Problem in determining location, see getam";
  }

  // Convert long and lat in decimal: 
  longitude= longitude(1)+longitude(2)/60.;
  latitude= latitude(1)+latitude(2)/60.;

  // parse date and time and convert in float:
  date= parseDate(strtrim(sxpar(hdr,"DATE-OBS")));
  time= parseTime(strtrim(sxpar(hdr,"TIME-OBS")));

  // Compute the JD:
  jdStart= jdcnv(date(1),date(2),date(3),time);

  // Compute the LST:
  lst= ct2lst(longitude,0.,jdStart);
  if (is_set(verbose)) {
    write,format="LST = %f ; RA = %f ; dec = %f\n",
      lst,sxpar(hdr,"RA"),sxpar(hdr,"DEC");
  }
  
  ha    = min(abs([lst-sxpar(hdr,"RA"),(24+lst)-sxpar(hdr,"RA")]));
  dec	= sxpar(hdr,"DEC");

  if (abs(ha) > 6) {
    print,"DATE-OBS (UT) = ",date;
    print,"TIME-OBS (UT) = ",time;
    print,"LST = ",lst;
    print,"RA = ",sxpar(hdr,"RA");
    exit,"Problem, HA is > 6 !";
  }

  // compute the elevation from the HA and dec:
  altaz,ha/12*180.,dec,latitude,alt,az;

  // Zenith angle:
  zenang= 90.-alt;
 
  if (is_set(verbose)) {
    write,format="Zenith angle = %f ; Airmass = %f\n",zenang,airmass(zenang);
  }

  return airmass(zenang);
}


func funkeep(x,a)
{
  // a = [sky,flux,Xcent,Ycent,Xfwhm,Yfwhm]
  y = a(1)+a(2)*exp(-( (abs(x(,,1)-a(3))/a(5))^2. + (abs(x(,,2)-a(4))/a(6))^2. )^a(7) );
  return y;
}

func gaussianRound(x,a)
{
  // FIXME: protect against zeros in next 3 functions (as in moffat)
  // a = [sky,Totalflux,Xcent,Ycent,~fwhm]
  a(3) = clip(a(3),-10,dimsof(x)(2)+10);
  a(4) = clip(a(4),-10,dimsof(x)(3)+10);
  a(5:6) = abs(a(5:6));
  // test:
  a(5:6) = (atan(a(5:6))+pi/2.)*8;
  // end test
  xp    = x(,,1)-a(3);
  yp    = x(,,2)-a(4);
  if (a(5)==0.) return a(1)+z*0.;
  z     = exp(-((xp/a(5))^2.+(yp/a(5))^2.));
  if (sum(z)==0) return a(1)+z;
  z     = a(1)+a(2)*z/sum(z);
  return z;
}

func lmfit_lim(a,dir)
/* DOCUMENT to be called within F(x,a) as
   a = lmfit_lim(a,1)
   to set limits to the range of possible a values
   and then to be called as
   a = lmfit_lim(a,-1)
   after spydr_lmfit has returned.
   also, add the extern statement to calling function.
   also, set the default values for the affected a to 0 (average value between
   min and max).
   SEE ALSO:
 */
{
  extern lmfit_amin,lmfit_amax;
  w = where(lmfit_amin!=lmfit_amax);
  if (numberof(w)!=0) {
    if (dir==1) {
      a(w) = (atan(a(w))/pi+0.5)*(lmfit_amax(w)-lmfit_amin(w))+lmfit_amin(w);
    } else if (dir==-1) {
      a(w) = tan(((a(w)-lmfit_amin(w))/(lmfit_amax(w)-lmfit_amin(w))-0.5)*pi);
    } else error,"dir has to be 1 (forward) or -1 (backward) ";
  }
  return a;
}
  
func gaussian(x,ai)
{
  local a; a=ai;

  // a = [sky,Totalflux,Xcent,Ycent,~Xfwhm,~Yfwhm,angle]
  a = lmfit_lim(a,1);
  alpha = a(7)/180.*pi;
  xp = (x(,,1)-a(3))*cos(alpha)+(x(,,2)-a(4))*sin(alpha);
  yp = -(x(,,1)-a(3))*sin(alpha)+(x(,,2)-a(4))*cos(alpha);
  r = sqrt(xp^2.+yp^2.);
  if (a(5)==0) {
    z = exp(-(yp/a(6))^2.);
  } else if (a(6)==0) {
    z = exp(-(xp/a(5))^2.);
  } else z = exp(-((xp/a(5))^2.+(yp/a(6))^2.));
  if (sum(z)==0) return a(1)+z;
  z = a(1)+a(2)*z/sum(z);
  return z;
}


func moffatRound(x,a)
{
  // a=[sky,total,xc,yc,a,coefpow]
  //  a6 = atan(a(6))/(pi/2.)+1.2;
  a1 = a(5);
  a(6)=clip(a(6),-30,30);
  xp = x(,,1)-a(3);
  yp = x(,,2)-a(4);
  //  z = (1. + ((xp/a1)^2.+(yp/a1)^2.))^(-a(6));
  if (a(6)==0) {
    z = 1.+zp*0.;
  } else {
    if (a1==0) {
      z = (1. + ((yp/a1)^2.))^(-a(6));
    } else {
      z = (1. + ((xp/a1)^2.+(yp/a1)^2.))^(-a(6));
    }
  }
  if (sum(z)==0) return a(1)+z;
  z = a(1)+a(2)*z/sum(z);
  return z;
}

func moffat(x,ai)
{
  local a; a=ai;
  // a=[sky,total,xc,yc,a,b,angle,coefpow]
  // alpha angle of longest axis clockwise
  //  a(8)=clip(a(8),-50,50);
  a = lmfit_lim(a,1);
  alpha = a(7)/180.*pi;
  a1  = a(5);
  a2  = a(6);
  xp = (x(,,1)-a(3))*cos(alpha)+(x(,,2)-a(4))*sin(alpha);
  yp = -(x(,,1)-a(3))*sin(alpha)+(x(,,2)-a(4))*cos(alpha);
  if (a(8)==0) {
    z = 1.+zp*0.;
  } else {
    if (a1==0) {
      z = (1. + ((yp/a2)^2.))^(-a(8));
    } else if (a2==0) {
      z = (1. + ((xp/a1)^2.))^(-a(8));
    } else {
      z = (1. + ((xp/a1)^2.+(yp/a2)^2.))^(-a(8));
    }
  }
  if (sum(z)==0) return a(1)+z;
  z = a(1)+a(2)*z/sum(z);
  return z;
}

func printhelp(void)
{
  write,"Yorick function to interactively measure FWHM on an image";
  write,
    "Syntax: yfwhm [-help] [-a -p pixelsize -b boxsize -f functype -e extnum -s saturation -mag -v] image";
}
func printlonghelp(void)
{
  write,"Yorick function to interactively measure FWHM on an image";
  write,"Version "+version+" / Last modified "+modifDate;
  write,"Syntax: yfwhm [-help] [-p pixelsize -b boxsize -mag] image";
  write,"-help          Prints this message";
  //  write,"-1             Uses only one window for graphic display";
  write,"-a             Outputs airmass corrected FWHM values";
  write,"-p pixelsize   Specify the image pixel size";
  write,"-b boxsize     Specify the size of the box of sub-images,";
  write,"               usually 4-10 times the fwhm";
  write,"-f functype    function to use for fit (gaussian,special,moffat)";
  write,"-e extnum      fits extension number (main = 1)";
  write,"-s saturation  Saturation value (prevent picking saturated stars)";
  write,"-mag           Output flux in magnitude (zp=spydr_zero_point is used)";
  write,"-v             Verbose mode (more chatty)";
}

func yfwhm(bim,onepass,xstar,ystar,fluxstar,boxsize=,saturation=,pixsize=,funtype=, \
           magswitch=,verbose=,airmass=)
/* DOCUMENT func yfwhm(image,boxsize=,saturation=,pixsize=,funtype=,
   magswitch=,nwindow=,verbose=,airmass=)
   image      = 2D image
   airmass    = airmass. Outputs airmass corrected FWHM values
   pixsize    = Specify the image pixel size
   boxsize    = Specify the size of the box of sub-images
   (usually 4-10 times the fwhm)
   funtype    = function to use for fit (gaussian,special,moffat
   saturation = Saturation value (prevents picking saturated stars)
   magswitch  =  Output flux in magnitude (zp=spydr_zero_point is used)
   nwindow    = Number of window for UI (default 2)
   verbose    = Verbose mode (0/1=more chatty)
   x and y: added 2007jun15 for compatibilty with spydr find mode.
            if x and y are set, then the interactive mode is turned off,
            and the (x,y) coordinates are looped on to produce the
            final yfwhmres (this function loops on the (x,y) and fit
            each image in turn).
*/
{
  extern spydr_fit_fwhm_estimate,imnum;
  extern spydr_fit_background_estimate;
  
  if (!is_set(boxsize)) boxsize = spydr_boxsize;
  if (!is_set(saturation)) saturation = spydr_saturation;
  if (!is_set(pixsize)) {pixsize = spydrs(imnum).pixsize;}
  if (pixsize!=1.0) pixset=1;
  if (!is_set(funtype)) {funtype = spydr_funtype;} else {funcset=1;};
  if (!is_set(magswitch)) magswitch= output_magnitudes;
  if (!is_set(airmass)) airmass = spydr_airmass;
  nwindow=2;
  if (!is_set(verbose)) verbose=0;

  if (!compute_strehl) {
    if (funtype == "gaussian") {write,"Using Gaussian fit";}
    if (funtype == "special") {write,"Using Special fit";}
    if (funtype == "moffat") {write,"Using Moffat fit";}
  }

  show_lower_gui,1;
  
  batch_mode = (xstar!=[]);

  if (batch_mode) {
    if (numberof(xstar)!=numberof(ystar)) \
      error,"X and Y are set but do not have the same dim";
    n_to_do = numberof(xstar);
    write,"Entering non interactive mode";
  }

  //  spydr_disp;
  window,spydr_wins(1);
  
  maskarg = array(1,narg);

  yfwhmres = s_yfwhmres();
  allres = [];

  local b,pow,zp,f,ferr,el,eler,an,airmass,dims,sky1,bim;
  
  b       = boxsize/2;
  // update zoom to match boxsize:
  rad4zoom = b;
  pow     = 0.85;
  zp      = spydr_zero_point;
  f       = array(float,2,1);
  ferr    = array(float,2,1);
  el      = 0.;
  eler    = 0.;
  an      = 0.;
  airmass = double(airmass);

  dims = (dimsof(bim))(2:3);
  
  sky1    = sky(bim,dev1);
  bim     = bim-sky1;
  if (saturation != 0.) {saturation -= sky1;}

  /* this is called from spydr, so the windows pre-exist. */

  if (onepass) {
    //    write,"Click on star";
  } else {
    write,"Left click on star for FWHM. Right click to exit.";
    write,"Middle click to remove last entry.";
  }
  
  if (onepass) spydr_pyk_status_push,"Click on star";
  else spydr_pyk_status_push,"BUTTONS: Left:Select Star / Middle:Remove last entry / Right:Exit.";

  if (!compute_strehl) {
    if (pixset) {
      if (!magswitch) {
        write,"X[pix]  Y[pix]      X FWHM[\"]      Y FWHM[\"]  FLUX[ADU] ELLIP  ANGLE    MAX";
      } else          {
        write,"X[pix]  Y[pix]      X FWHM[\"]      Y FWHM[\"]  MAGNITUDE ELLIP  ANGLE    MAX";
      } 
    } else {
      if (!magswitch) {
        write,"X[pix]  Y[pix]    X FWHM[pix]    Y FWHM[pix]  FLUX[ADU] ELLIP  ANGLE    MAX";
      } else          {
        write,"X[pix]  Y[pix]    X FWHM[pix]    Y FWHM[pix]  MAGNITUDE ELLIP  ANGLE    MAX";
      } 
    }
  }

  local nloop;
  nloop=1;
  
  do {
    if (batch_mode) {
      c = long(_(xstar(nloop),ystar(nloop)));
      if (nloop==n_to_do) but=3; else but=1;  // but=3 will exit main loop
    } else { // interactive mode
      res  = mouse(1,0,"");
      if (spydr_plot_in_arcsec) res(1:4) = spydr_arcsec_to_pixels(res(1:4));
      spydr_pyk_status_push,"Processing...";
      c    = long(res(1:2));
      but  = res(10);
      if (but == 3) break;
      if (but == 2) {
        if (numberof(el) == 1) {
          write,"You can only unbuffer after having buffered at least one star!";
          spydr_pyk_warning,"You can only unbuffer after having buffered at least one star!";
          continue;
        }
        f    = f(,:-1);
        ferr = ferr(,:-1);
        el   = el(:-1);
        eler = eler(:-1);
        an   = an(:-1);
        write,"Last measurement taken out of star list";
        spydr_pyk_warning,"Last measurement taken out of star list";
        continue;
      }
    }

    i1 = clip(c(1)-b,1,);
    i2 = clip(c(1)+b,,dims(1));
    j1 = clip(c(2)-b,1,);
    j2 = clip(c(2)+b,,dims(2));
    
    im   = smooth(bim(i1:i2,j1:j2),2);
    wm   = where2(im == max(im))(*)(1:2)-b-1;
    c    = c + wm;
    im   = bim(i1:i2,j1:j2);
    pos  = c(1:2)-b;
    pos  = [i1,j1]-1;
    //    im   = sigmaFilter(im,5,iter=2,silent=1);
    if ((saturation > 0) && (max(im) > saturation)) {
      if (onepass) {
      write,"Some pixels > specified saturation level. Aborting !";
      spydr_pyk_status_push,"Some pixels > specified saturation level. Aborting !";
        exit;
      } else {
        write,"Some pixels > specified saturation level. Choose another star";
        spydr_pyk_status_push,"Some pixels > specified saturation level. Choose another star";
      continue;
      }
    }
    sky2 = sky(im,dev2);
    im   = im - sky2;
    d    = dimsof(im);

    w    = 1.+0.*clip(im,dev2,)^2;

    x    = indices(d);

    if (catch(0x11)) {
      if (onepass) {
        write,"Error detected, exiting.";
        spydr_pyk_status_push,"Error detected, exiting.";
        return;
      }
      write,"Error detected, skipping source";
      spydr_pyk_status_push,"Error detected, skipping source";
      nloop++;
      continue;
    }
    
    extern lmfit_amin,lmfit_amax;

    if (compute_strehl==0) {
      if (funtype == "gaussian") {
        // a = [sky,Totalflux,Xcent,Ycent,fwhm_parameter]
        ai    = [0,sum(im-median(im(*))),d(2)/2.,d(3)/2.,4.];
        if (batch_mode) { // we've been given (guessed) coordinates, use them
          ai = [0,fluxstar(nloop)*10.,xstar(nloop)-i1+1,ystar(nloop)-j1+1,spydr_fit_fwhm_estimate];
        }
        //r=spydr_lmfit(gaussianRound,x,ai,im,w,tol=1e-6,itmax=50,silent=1);
        //ai(5)=abs(ai(5);
        //a=[sky,Totalflux,Xcent,Ycent,a,b,angle]
        a     = [ai(1),ai(2),ai(3),ai(4),ai(5),ai(5),0.];
        if (batch_mode) {
          lmfit_amin = [0,0,a(3)-3,a(4)-3,a(5)-2,a(6)-2,0];
          lmfit_amax = [0,0,a(3)+3,a(4)+3,a(5)+2,a(6)+2,0];
          a(3:6) *=0.;
        } else { // interative, no constraints.
          lmfit_amin = [0,0,0,0,0,0,0];
          lmfit_amax = [0,0,0,0,0,0,0];
        }
        r     = spydr_lmfit(gaussian,x,a,im,w,stdev=1,tol=1e-8,itmax=50,silent=1);
        tmp   = gaussian(x,a);
        a = lmfit_lim(a,1);
        a(5:6) = abs(a(5:6));
        err   = *r.stdev;
        pos     = pos + a(3:4)-0.5;
        angle = (a(7) % 180.) ;
        angle  -= 90.;   // w.r.t. vertical axis instead of horizontal axis.
        if (a(5) < a(6)) {
          tmp2 = a(5); a(5) = a(6); a(6) = tmp2;
          angle += 90;
        }
        while (angle > 90)  angle -= 180.;
        while (angle < -90) angle += 180.;
        //if (angle < 0) {angle = angle+180.;}
        //if (a(5) < a(6)) {angle = angle+90;}
        //angle = (angle % 180.) ;
        fwhm  =  a(5:6)*2*(-log(0.5))^(1./2.)*pixsize; //gaussian
        fwhmerr = err(5:6)*2*(-log(0.5))^(1./2.)*pixsize;
        fwhm  = fwhm/airmass^0.6; fwhmerr = fwhmerr/airmass^0.6;
        ellip = abs(fwhm(2)-fwhm(1))/avg(fwhm);
        ellerr= 2*(fwhmerr(1)+fwhmerr(2))*(2*fwhm(2))/(fwhm(1)+fwhm(2))^2.;
        
      } else if (funtype == "moffat") {
        
        // a    = [sky,total,xc,yc,fwhm_parameter,beta]
        ai      = [0,sum(im-median(im(*))),d(2)/2.,d(3)/2.,5.,1.7];
        if (batch_mode) { // we've been given (guessed) coordinates, use them
          if (spydr_fit_fwhm_estimate==[]) spydr_fit_fwhm_estimate=3.;
          ai = [0,fluxstar(nloop)*10.,xstar(nloop)-i1+1,ystar(nloop)-j1+1,
                clip(spydr_fit_fwhm_estimate,2.1,),1.7];
        }
        // r = spydr_lmfit(moffatRound,x,ai,im,w,tol=1e-6,itmax=50,silent=1);
        // a    = [sky, total, xc,   yc,   a,    b,     angle,beta]
        a       = [ai(1),ai(2),ai(3),ai(4),ai(5),ai(5),0.,ai(6)];
        //      a     = [ai(1),ai(2),ai(3),ai(4),ai(5),ai(5),0.];
        if (batch_mode) {
          lmfit_amin = [0,0,a(3)-3,a(4)-3,a(5)-2,a(6)-2,0,1.];
          lmfit_amax = [0,0,a(3)+3,a(4)+3,a(5)+2,a(6)+2,0,3.];
          a(3:6) *=0.;
        } else { // interative, no constraints.
          lmfit_amin = [0,0,0,0,0,0,0,0];
          lmfit_amax = [0,0,0,0,0,0,0,0];
        }
        fit = [1,2,3,4,5,6,7,8];
        r       = spydr_lmfit(moffat,x,a,im,w,stdev=1,tol=2e-8,itmax=50,silent=1,fit=fit);
        tmp     = moffat(x,a);
        a = lmfit_lim(a,1);
        a(5:6)  = abs(a(5:6));
        err     = *r.stdev;
        pos     = pos + a(3:4)-0.5;
        angle   = (a(7) % 180.) ; //write,format="%f %f %f\n",a(5),a(6),angle;
        angle  -= 90.;   // w.r.t. vertical axis instead of horizontal axis.
        if (a(5) < a(6)) {
          tmp2 = a(5); a(5) = a(6); a(6) = tmp2;
          angle += 90;
        }
        while (angle > 90)  angle -= 180.;
        while (angle < -90) angle += 180.;
        
        fwhm    =  2*a(5:6)*sqrt(0.5^(-1./a(8))-1.)*pixsize; // moffat
        fwhmerr = fwhm*(err(5:6)/a(5:6)+
                        0.5*abs(log(0.5))*err(8)/a(8)^2.*0.5^(1./a(8))/(0.5^(1./a(8))-1.));
        fwhm = fwhm/airmass^0.6; fwhmerr = fwhmerr/airmass^0.6;
        fwhmerr = fwhmerr(sort(fwhm)(::-1));
        fwhm    = fwhm(sort(fwhm)(::-1));
        ellip   = (fwhm(1)-fwhm(2))/avg(fwhm);
        ellerr  = 2*(fwhmerr(1)+fwhmerr(2))*(2*fwhm(2))/(fwhm(1)+fwhm(2))^2.;
      }
      
      maxim = max(tmp);
      window,spydr_wins(3);
      tv,transpose(grow(transpose(im),transpose(tmp),
                        transpose(im-tmp+a(1)))),square=1;
      plt,"image",0.201,0.89,tosys=0;
      plt,"fit",0.357,0.89,tosys=0;
      plt,"image-fit",0.51,0.89,tosys=0;
      spydr_xytitles,"pixels","pixels";
      window,spydr_wins(1);

      grow,f,fwhm;
      grow,ferr,fwhmerr;
      grow,el,ellip;
      grow,eler,ellerr;
      grow,an,angle;

      if (magswitch) {flux = zp-2.5*log10(clip(a(2),1e-10,));} else {flux = a(2);}
    
      yfwhmres.xpos = pos(1);
      yfwhmres.ypos = pos(2);
      yfwhmres.xposerr = (*r.stdev)(3);
      yfwhmres.yposerr = (*r.stdev)(4);
      yfwhmres.xfwhm = fwhm(1);
      yfwhmres.yfwhm = fwhm(2);
      yfwhmres.xfwhmerr = fwhmerr(1);
      yfwhmres.yfwhmerr = fwhmerr(2);
      yfwhmres.flux = flux;
      yfwhmres.fluxerr = (*r.stdev)(2);
      yfwhmres.el = ellip;
      yfwhmres.elerr = ellerr;
      yfwhmres.angle = angle;
      yfwhmres.maxim = maxim;
      yfwhmres.background = a(1)+sky1+sky2;

      grow,allres,yfwhmres;

      msg=swrite(format="%7.2f %7.2f %6.3f+/-%5.3f %6.3f+/-%5.3f  %9.1f  %4.2f %6.2f %6.1f",
                 pos(1),pos(2),fwhm(1),fwhmerr(1),fwhm(2),fwhmerr(2),flux,ellip,angle,maxim);
      write,format="%s\n",msg;
      
      msg=swrite(format="  x=%.2f | y=%.2f | xfwhm=%.3f | yfwhm=%.3f | flux=%.1f | ell=%.2f | ang=%.2f | max=%.1f | bckgrd=%.1f",
                 pos(1),pos(2),fwhm(1),fwhm(2),flux,ellip,angle,maxim,a(1)+sky1+sky2);
      msg = msg+" ("+funtype+")";
      
    } else if (compute_strehl) {

      if (pixset==0) {
        spydr_pyk_error,"Need pixsize set to compute Strehl!";
        return;
      }
      if (spydrs(imnum).wavelength==0) {
        spydr_pyk_warning,"Need wavelength to compute Strehl!";
        return;
      }
      
      // determination of background
      sdim = dimsof(im)(2);
      rmask = spydr_strehlmask/pixsize;
      smask = (dist(sdim)>rmask);
      psky = im(where(smask)); // outside of disk
      nsig=4.;
      // first pass:
      w = where( (psky>(median(psky)-psky(rms)*nsig)) & (psky<(median(psky)+psky(rms)*nsig)) );
      skyavg = psky(w)(avg);
      skyrms = psky(w)(rms);
      // second pass:
      w = where( (psky>(skyavg-skyrms*nsig)) & (psky<(skyavg+skyrms*nsig)) );
      hy = histo2(psky(w),hx);
      ag = [max(hy),hx(wheremax(hy)(1)),3.];
      clmfit,float(hy),hx,ag,"a(1)*exp(-0.5*((x-a(2))/a(3))^2.)",yfit;
      skyavg = ag(2);
      skyrms = ag(3)*2.355;
      // plots:
      curw = current_window();
      window,spydr_wins(3);
      fma; limits,square=0; limits;
      plh,hy,hx;
      plh,yfit,hx,color="red";
      spydr_pltitle,swrite(format="Background and fit (avg=%f, rms=%f)",skyavg,skyrms);
      spydr_xytitles,"value","number in bin";
      window,curw;
      //write,format="a(1) = %f ; sky = %f +/- %f\n",a(1),skyavg,skyrms;

      fwhmStrehl,im-skyavg,pixsize,spydrs(imnum).wavelength,spydr_teldiam, \
        spydr_cobs,pstrehl,pfwhm,rmask=rmask,silent=1,source=spydr_sourcediam;

      // apply fudge
      pstrehl *= spydr_strehlfudge;
      
      // plot boxes
      plg,[j2,j2,j1,j1,j2],[i1,i2,i2,i1,i1],color="red";
      plt,"Sky",i1+1,j2-1,justify="LT",tosys=1,color="red";
      tmp = span(0.,2*pi,100);
      plg,(j2+j1)/2.+1+rmask*sin(tmp),(i2+i1)/2.+1+rmask*cos(tmp),color="red";
      // print results
      nptvalid = pi*rmask^2.;
      nptsky = numberof(w);
      strehl_err = skyrms/sqrt(nptsky)*nptvalid/max(im)*pstrehl;
      // note: FIXME. This is just the strehl error due to the estimation
      // of the average sky. There is an additional component
      // due to the noise within the aperture.
      msg = swrite(format="FWHM = %.3f | strehl = %.2f",pfwhm,pstrehl);
      write,format="%s wvl=%.3f FWHM=%.3f Strehl=%.2f +/- %.2f (fudge=%.3f)\n",\
        spydrs(imnum).name,spydrs(imnum).wavelength,pfwhm,pstrehl, \
        strehl_err,spydr_strehlfudge;
      //yfwhmres.pstrehl = pstrehl;
      //yfwhmres.pfwhm = pfwhm;
    }

    spydr_pyk_status_push,msg;

    if (onepass) break;
    //    typeReturn;
    nloop++;
  } while (but != 3);
  

  if (!compute_strehl) {
    f     = f(,2:);
    ferr  = ferr(,2:);
    el    = el(2:);
    eler  = eler(2:);
    avgfwhm = sum((f*1./ferr)(*))/sum(1./ferr(*));
    //  stdfwhm = f(*)(rms);
    stdfwhm = avg([f(1,)(rms),f(2,)(rms)]); // avg X and Y rms
    avgel   = avg(el);
    stdel   = el(rms)+sqrt(sum(eler^2.))/numberof(eler);

    if (pixset) {
      msg=swrite(format="Median FWHM : X = %5.3f / Y = %5.3f / <XY> = %6.3f [arcsec]",
                 median(f(1,)),median(f(2,)),avg([median(f(1,)),median(f(2,))]));
    } else {
      msg=swrite(format="Median FWHM : X = %6.3f / Y = %6.3f / <XY> = %6.3f [pixel]",
                 median(f(1,)),median(f(2,)),avg([median(f(1,)),median(f(2,))]));
    }
    write,format="\n%s\n",msg;
    if (!onepass) spydr_pyk_status_push,msg;
    // in pixels:
    spydr_fit_fwhm_estimate = avg([median(f(1,)),median(f(2,))])/pixsize;
    spydr_fit_background_estimate = avg(allres.background);
  } else { // compute_strehl
    spydr_fit_fwhm_estimate = pfwhm/pixsize;
    spydr_fit_background_estimate = skyavg;
  }
    
  spydr_pyk,swrite(format="y_text_parm_update('find_fwhm','%.3f')",spydr_fit_fwhm_estimate);

  if (compute_strehl) return _(pfwhm,pstrehl);
  else return allres;
}


require, "random.i";

struct lmfit_result {
  /* DOCUMENT lmfit_result -- structure returned by lmfit
   */
  long	neval;
  long	niter;
  long	nfit;
  long	nfree;
  long	monte_carlo;
  double	chi2_first;
  double	chi2_last;
  double	conv;
  double	sigma;
  double	lambda;
  pointer	stdev;
  pointer	stdev_monte_carlo;
  pointer	correl;
};

func spydr_lmfit(f, x, &a, y, w, fit=, correl=, stdev=, gain=, tol=, deriv=, itmax=,
           lambda=, eps=, monte_carlo=,silent=)
/* DOCUMENT spydr_lmfit
   Non-linear least-squares fit by Levenberg-Marquardt method.
   This is a local copy, slightly modified, of lmfit.i (in yutils).
   For help, please refer to the lmfit document section.
   In general, use lmfit instead of spydr_lmfit.
*/
{
  local grad;

  /* Maybe subset of parameters to fit. */
  if (structof(a)!=double) {
    a+= 0.0;
    if (structof(a)!=double)
      error, "bad data type for parameters (complex unsupported)";
  }
  na= numberof(a);
  if (is_void(fit))
    fit= indgen(na);
  else if (dimsof(fit)(1) == 0)
    fit= [fit];
  nfit= numberof(fit);
  if (!nfit)
    error, "no parameters to fit.";
    
  /* Check weights. */
  if (is_void(w)) w= 1.0;
  else if (anyof(w < 0.0))
    error, "bad weights.";
  if (numberof(w) != numberof(y))
    w += array(0.0, dimsof(y));
  nfree= sum(w != 0.0) - nfit;	// Degrees of freedom
  if (nfree <= 0)
    error, "not enough data points.";

  /* Other settings. */
  diag= indgen(1:nfit^2:nfit+1);	// Subscripts of diagonal elements
  if (is_void(lambda)) lambda= 1e-3;
  if (is_void(gain)) gain= 10.0;
  if (is_void(itmax)) itmax= 100;
  if (is_void(eps)) eps= 1e-6;	// sqrt(machine_precision)/100
  if (1.0+eps <= 1.0)
    error, "bad value for EPS.";
  if (is_void(tol)) tol= 1e-7;
  monte_carlo= is_void(monte_carlo) ? 0 : long(monte_carlo);
  warn_zero= 0;
  warn= "*** Warning: spydr_lmfit ";
  neval= 0;
  conv= 0.0;
  niter= 0;
    
  while (1) {
    if (deriv) {
      m= f(x, a, grad, deriv=1);
      neval++;
      grad= nfit == na ? grad(*,) : grad(*,fit);
    } else {
      if (!niter) {
        m= f(x, a);
        neval++;
      }
      inc= eps * abs(a(fit));
      if (numberof((i= where(inc <= 0.0)))) inc(i)= eps;
      grad= array(double, numberof(y), nfit);
      for (i=1; i<=nfit; i++) {
        anew= a;	// Copy current parameters
        anew(fit(i)) += inc(i);
        grad(,i)= (f(x,anew)-m)(*)/inc(i);
      }
      neval += nfit;
    }
    beta= w * (chi2= y-m);
    if (niter) chi2= chi2new;
    else       chi2= chi2_first= sum(beta * chi2);
    beta= grad(+,) * beta(*)(+);
    alpha= ((w(*)(,-) * grad)(+,) * grad(+,));
    gamma= sqrt(alpha(diag));
    if (anyof(gamma <= 0.0)) {
      /* Some derivatives are null (certainly because of rounding
       * errors). */
      if (!warn_zero) {
        if (!silent) write, warn+"founds zero derivatives.";
        warn_zero= 1;
      }
      gamma(where(gamma <= 0.0))= eps * max(gamma);
      if (allof(gamma<=0.0)) goto done; // case where all gamma=0
    }
    gamma= 1.0 / gamma;
    beta *= gamma;
    alpha *= gamma(,-) * gamma(-,);
	
    while (1) {
      alpha(diag)= 1.0 + lambda;
      anew= a;
      anew(fit) += gamma * LUsolve(alpha, beta);
      m= f(x, anew);
      neval++;
      d= y-m;
      chi2new= sum(w*d*d);
      if (chi2new < chi2)
        break;
      lambda *= gain;
      if (allof(anew == a)) {
        /* No change in parameters. */
        if (!silent) write, warn+"makes no progress.";
        goto done;
      }
    }
    a= anew;
    lambda /= gain;
    niter++;
    conv= 2.0*(chi2-chi2new)/(chi2+chi2new);
    if (conv <= tol)
      break;
    if (niter >= itmax) {
      if (!silent) {
        write, format=warn+"reached maximum number of iterations (%d).\n",
          itmax;
      }
      break;
    }
  }
    
 done:
  sigma= sqrt(nfree/chi2);
  result= lmfit_result(neval=neval, niter=niter, nfree=nfree, nfit=nfit,
                       lambda=lambda, chi2_first=chi2_first, chi2_last=chi2, conv=conv,
                       sigma=sigma);
  if (correl || stdev) {
    /* Compute correlation matrice and/or standard deviation vector. */
    alpha(diag)= 1.0;
    alpha= LUsolve(alpha);
    if (anyof((tmp1= alpha(diag)) < 0.0))
      write, format=warn+"%s\n", "found negative variance(s)";
    tmp1= sqrt(abs(tmp1));
    if (stdev) {
      /* Standard deviation is rescaled assuming that statistically
       * chi2 = nfree +/- sqrt(2*nfree). */
      (tmp2= array(double,na))(fit)= gamma * tmp1 / sigma;
      result.stdev= &tmp2;
    }
    if (correl) {
      gamma= 1.0 / tmp1;
      alpha *= gamma(-,) * gamma(,-);
      if (nfit == na) {
        result.correl= &alpha;
      } else {
        (tmp2= array(double, na, na))(fit,fit)= alpha;
        result.correl= &tmp2;
      }
    }
  }
  alpha= beta= gamma= [];	// Free some memory.
  if (monte_carlo >= 1) {
    saa= 0.0*a;
    sig= (w > 0.0) /(sqrt(max(nfree/chi2*w, 0.0)) + (w == 0.0));
    for (i=1; i<=monte_carlo; i++) {
      anew= a;
      //	    ynew= y + sig * random_normal(dimsof(y));
      ynew= y + sig * random_n(dimsof(y));
      spydr_lmfit, f, x, anew, ynew, w, fit=fit, gain=gain, tol=tol,
        deriv=deriv, itmax=itmax, lambda=lambda, eps=eps;
      anew -= a;
      saa += anew * anew;
    }
    result.monte_carlo= monte_carlo;
    result.stdev_monte_carlo= &sqrt(saa / monte_carlo);
  }
  return result;
}
