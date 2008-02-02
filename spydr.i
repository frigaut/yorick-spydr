/* spydr.i
 * main function to call the pygtk GUI to spydr.
 * syntax: yorick -i spydr.i imname ... (see README)
 *
 * This file is part of spydr, an image viewer/data analysis tool
 *
 * $Id: spydr.i,v 1.23 2008-02-02 05:18:08 frigaut Exp $
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
 * $Log: spydr.i,v $
 * Revision 1.23  2008-02-02 05:18:08  frigaut
 * fixed log header in spydr.i
 *
 * Revision 1.22  2008/02/02 05:12:05  frigaut
 * fixed bug when picking star for fitting while being in "graphical axis
 * in arcsec" mode.
 *
 * Revision 1.21  2008/02/02 04:59:54  frigaut
 * saved fits is displayed fits, not stack image
 *
 * revision 1.20  2008/02/02 04:49:21  frigaut
 * many changes once more:
 * - can now display graphes with X/Y axis in arcsec
 * - cleaned up mode switching (tv/contours/surface). Now more reliable.
 * - contour filled and tv switch survive a mode switching (before, were
 *   reset)
 * - limits are sticky between switch of mode (especially when switching
 *   to contours)
 * - when axis in arcsec is selected, gaussian fit is expresed in arcsec too.
 * - added export to pdf, postscript, encapsulated postscript
 * - added menu to pick color of contour lines
 * - added menu to pick color of contour marks
 * - implemented contour legends on plots
 * - added menu to select position of contour legends
 * - new functionality to compute distance between 2 points (see shortcut
 *   "M" and "m").
 * - rebin now works both ways (increasing and decreasing number of pixels)
 * - added "hdu" command line keyword, and updated manpage.
 * - added hist-equalize option to LUT
 * this is version 0.7.3
 *
 * Revision 1.19  2008/01/30 05:28:19  frigaut
 * - added spydr_pyk to avoid conflicts with other calls of pyk, and modify
 * spydr_pyk for our purpose. I know this means we will not benefit from
 * future pyk code improvements, but I can deal with that.
 * - added check of yorick main version to avoid use with V<2.1.05 (in which
 * current_mouse does not exist)
 *
 * Revision 1.18  2008/01/29 21:23:46  frigaut
 * - upgraded version 0.7.2
 * - added "save as", "save" and export to jpeg and png menus/actions
 *
 * Revision 1.17  2008/01/25 15:41:40  frigaut
 * bumped version to 0.7.1
 *
 * Revision 1.16  2008/01/25 03:03:49  frigaut
 * - updated license or license text to GPLv3 in all files
 *
 * Revision 1.15  2008/01/25 02:55:11  frigaut
 * - updated DOCUMENT section of spydr
 *
 * Revision 1.14  2008/01/24 15:05:17  frigaut
 * - added "delete from stack" feature
 * - some bugfix in psffit
 *
 * Revision 1.13  2008/01/23 21:20:40  frigaut
 * - update doc to add (forgotten) --compact command line option
 *
 * Revision 1.12 2008/01/23 21:11:22  frigaut
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
 * - bug: sometimes the next/previous image does not register
 *  
 * Revision 1.11  2008/01/17 14:49:49  frigaut
 * - fixed problem with (spydr_pyk) I/O interupt, which was due to calling spydr_pyk_flush
 *    prematurely. Now called within first call of spydr()
 *
 * Revision 1.10  2008/01/17 13:17:44  frigaut
 * - bumped version to 0.6.1
 *
 * Revision 1.9  2008/01/03 17:59:49  frigaut
 * removed spydr.spec (moved name to yorick-spydr)
 *
 * Revision 1.8  2008/01/02 14:11:42  frigaut
 * - better fit of graphical area in GUI
 * - updated spec file
 *
 * Revision 1.7  2007/12/26 21:55:56  frigaut
 * - updated Makefile for package use (instead of plugin)
 * - bumped to 0.6.0
 *
 * Revision 1.6  2007/12/26 17:41:47  frigaut
 * - removed dependency on usleep in info file
 * - bumped to 0.5.3
 *
 * Revision 1.5  2007/12/24 17:16:52  frigaut
 * bumped to version 0.5.2
 * don't know why mouse-nowait.c is in here (no diff)
 *
 * Revision 1.4  2007/12/17 20:54:47  frigaut
 * - added set/unset debug of yorick/python communication in GUI help menu
 * - gotten rid of usleep calls and replaced by flush of pipe every seconds
 *   (as for yao)
 * - added debug from python side (set pyk_debug)
 *
 * Revision 1.3  2007/12/17 13:29:05  frigaut
 * - fixed typo in Makefile uninstall rule
 * - updated one filter in nici filter list
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

spydr_version = "0.7.2";


require,"spydr_pyk.i";
require,"astro_util1.i";
require,"spydr_psffit.i";
require,"util_fr.i";
require,"histo.i";
require,"plot.i";
require,"spydr_plugins.i";
require,"pathfun.i";
require,"imutil.i";

struct spydr_struct{
  pointer pim;
  long    nim;
  long    dims(3);
  double  opixsize; // original image pixel size (arcsec/pixel)
  double  pixsize;  // current image pixel size (can be rebinned)
  double  wavelength;
  string  name;
  string  saveasname;
  float   cmin;     // zcut min
  float   cmax;     // zcut max
  string  space;    // name of image space
};

flushing_interval=0.2;
rebin_fact=1;
//=============================
//  SPYDR_PYK wrapping functions
//=============================


func spydr_pyk_status_push(msg,id=)
{
  if (id==[]) id=1;
  spydr_pyk,swrite(format="pyk_status_push(%d,'%s')",id,msg);
}


func spydr_pyk_status_pop(id=)
{
  if (id==[]) id=1;
  spydr_pyk,swrite(format="pyk_status_pop(%d)",id);
}


func spydr_pyk_info(msg)
{
  if (numberof(msg)>1) msg=sum(msg+"\\n");
  // or streplace(msg,strfind("\n",msg),"\\n")
  spydr_pyk,swrite(format="pyk_info('%s')",msg);
}


func spydr_pyk_info_w_markup(msg)
{
  if (numberof(msg)>1) msg=sum(msg+"\\n");
  // or streplace(msg,strfind("\n",msg),"\\n")
  spydr_pyk,swrite(format="pyk_info_w_markup('%s')",msg);
}


func spydr_pyk_error(msg)
{
  if (numberof(msg)>1) msg=sum(msg+"\\n");
  // ok, here the problem is that "fatal errors", when called from shell,
  // should bail you out (quit yorick). But if they do, then the python
  // process is also killed and then the error message never appears on screen.
  // thus the use of zenity in *all* cases.
  //  if (_spydr_pyk_proc) {
  //    spydr_pyk,swrite(format="pyk_error('%s')",msg);
  //  } else { // python not started yet, use zenity
    system,swrite(format="zenity --error --text=\"%s\"",msg);
    //  }
}


func spydr_pyk_warning(msg)
{
  if (numberof(msg)>1) msg=sum(msg+"\\n");
  spydr_pyk,swrite(format="pyk_warning('%s')",msg);
}


func gui_progressbar_frac(frac) {
  spydr_pyk,swrite(format="progressbar.set_fraction(%f)",float(frac));
}


func gui_progressbar_text(text) {
  spydr_pyk,swrite(format="progressbar.set_text('%s')",text);
}


func gui_message(msg) {
  spydr_pyk,swrite(format="statusbar.push(1,'%s')",msg);
}


//=============================
// Window management functions
// and basic display operations
//=============================


func spydr_win_init(pid1,pid2,pid3)
{
  extern gui_realized;
  gui_realized=1;
  
  window,spydr_wins(1),dpi=spydr_dpi,wait=1,\
    xpos=-2,ypos=-2,style="spydr.gs",parent=pid1;
  if (imnum) {
    disp_cpc;
    disp_tv;
  }
  limits,square=1;
  window,spydr_wins(2),dpi=31,wait=1,style="nobox.gs",parent=pid2,\
    ypos=-27,xpos=-4;
  limits,square=1;
  window,spydr_wins(3),dpi=spydr_dpi,wait=spydr_showlower,style="spydr2.gs",\
    xpos=-2,ypos=-2,parent=pid3;
  window,spydr_wins(1);
  spydr_pyk,"done_init = 1";
  spydr_set_lut,spydr_lut;
  if (spydr_nim>0) {
    set_imnum,1;
    gui_update;
    disp_cpc;
    spydr_disp;
    if (spydr_showlower) plot_histo;
  }
}


func switch_disp(type)
{
  extern spydr_disp;
  extern from_disp,old_limits;
  extern surface_init;

  if (type==1) {  // TV
    spydr_disp = disp_tv;
    if (from_disp==3) limits,old_limits;
    from_disp=1;
  } else if (type==2) { // CONTOURS
    if (from_disp!=3) old_limits=limits();
    spydr_disp = disp_contours;
    //    if (from_disp==3) explimits,old_limits;
    explimits,old_limits;
    from_disp=2;
  } else if (type==3) { // SURFACE
    if (from_disp!=3) {
      old_limits=limits();
      spydr_disp = disp_surface;
      surface_init=1;
      //      window,1,style="nobox.gs";
      from_disp=3;
    }
  } else if (type==4) { // CONTOURS + TV
    spydr_disp = disp_contours_plus_tv;
    if (from_disp==3) limits,old_limits;
    from_disp=4;
  }
  spydr_disp;
}

func explimits(lim)
{
  limits,lim(1),lim(2),lim(3),lim(4);
}

func disp_tv(void)
// pli display, main window
{
  extern imnum;
  extern spydr_imd,spydr_imdnum;

  if (imnum==[]) return;
  //  write,format="%s ","*";
  window,spydr_wins(1);
  fma;

  if (spydr_itt==5) {
    if (nallof(spydr_imdnum==[imnum,spydr_itt,rebin_fact])) \
      spydr_imd = spydr_histeq_scale(spydr_im);
  } else spydr_imd = bytscl(spydr_im,cmin=cmin,cmax=cmax);
  spydr_imdnum = [imnum,spydr_itt,rebin_fact];
  
  if (spydr_plot_in_arcsec) {
    pli,spydr_imd,spydrs(imnum).dims(2)*spydrs(imnum).pixsize,\
      spydrs(imnum).dims(3)*spydrs(imnum).pixsize;
    axtit = "arcsec";
  } else {
    pli,spydr_imd;
    axtit = "pixels";
  }
  spydr_pltitle,spydrs(imnum).name+swrite(format=" %dx%d",spydrs(imnum).dims(2),spydrs(imnum).dims(3));
  spydr_xytitles,axtit,axtit;
  colorbar,adjust=-0.024,levs=10;
  // refresh zoom now
  disp_zoom,once=1;
}
spydr_disp = disp_tv;
  


func disp_contours(void,nofma=)
// contour display, main window
{
  extern spydr_width,spydr_ccolor;
  
  window,spydr_wins(1);
  if (nofma!=1) fma;

  if (spydr_plot_in_arcsec) {
    fact = spydrs(imnum).pixsize;
    axtit = "arcsec";
  } else {
    fact = 1.0f;
    axtit = "pixels";
  }
  
  xy = indices(spydrs(imnum).dims)-0.5;
  levs = span(cmin,cmax,spydr_nlevs)(2:-1);
  if (spydr_filled) {
    plfc,spydr_im,xy(,,2)*fact,xy(,,1)*fact,levs=levs;
    colorbar,adjust=-0.024,levs=10;
  }
  ccolor="fg";
  if (spydr_ccolor==[]) spydr_ccolor="fg";
  if (spydr_mcolor==[]) spydr_mcolor="fg";
  if (spydr_width==[]) spydr_width=1;
  if ((nofma)||(spydr_filled)) ccolor=spydr_ccolor;
  
  plc,spydr_im,xy(,,2)*fact,xy(,,1)*fact,levs=levs,smooth=spydr_smooth,marker='A',\
    msize=1.2,mspace=0.2,color=ccolor,width=spydr_width,mcolor=spydr_mcolor;
  spydr_pltitle,spydrs(imnum).name+swrite(format=" %dx%d",spydrs(imnum).dims(2),spydrs(imnum).dims(3));
  spydr_xytitles,axtit,axtit;
  levstr = sum(swrite(format="%.1f",levs)+", ");
  levstr = "["+strpart(levstr,:-2)+"]";
  spydr_clegends,levs;
  //  spydr_pyk_status_push,"levels="+levstr;
  //  limits,old_limits; //(1),old_limits(2),old_limits(3),old_limits(4);
}

func spydr_clegends(levs)
{
  local x,y,spacing,just;
  extern spydr_clabel;

  if (spydr_clabel==[]) spydr_clabel="clabeltopleft";

  if (spydr_clabel=="clabelnone") return;

  nlevs = numberof(levs);
  vp = viewport();
  spacing = (vp(4)-vp(3))/30.;

  if (spydr_clabel=="clabeltopleft") {
    x = vp(1)+(vp(2)-vp(1))/40.;
    y = vp(4)-spacing/2.;
    just="LT";
  } else if (spydr_clabel=="clabeltopright") {
    x = vp(2)-(vp(2)-vp(1))/40.;
    y = vp(4)-spacing/2.;
    just="RT";
  } else if (spydr_clabel=="clabelbottomleft") {
    x = vp(1)+(vp(2)-vp(1))/40.;
    y = vp(3)+spacing/2.+nlevs*spacing;
    just="LT";
  } else if (spydr_clabel=="clabelbottomright") {
    x = vp(2)-(vp(2)-vp(1))/40.;
    y = vp(3)+spacing/2.+nlevs*spacing;
    just="RT";
  }
  for (i=1;i<=nlevs;i++) {
    s = string(&char(64+i))+swrite(format=" %+.2e",levs(i));
    plt,s,x,y,tosys=0,justify=just,font="courier",height=10,color=spydr_mcolor;
    y-=spacing;
  }
}

func spydr_histeq_scale(z, top=, cmin=, cmax=)
/* DOCUMENT histeq_scale(z, top=top_value, cmin=cmin, cmax=cmax)
     returns a byte-scaled version of the array Z having the property
     that each byte occurs with equal frequency (Z is histogram
     equalized).  The result bytes range from 0 to TOP_VALUE, which
     defaults to one less than the size of the current palette (or
     255 if no pli, plf, or palette command has yet been issued).

     If non-nil CMIN and/or CMAX is supplied, values of Z beyond these
     cutoffs are not included in the frequency counts.

     Identical to histeq_scale except it uses sedgesort instead of sort.
     faster for arrays for which many elements are repeated (e.g.
     CCD arrays where pixels values are integers.
   SEE ALSO: bytscl, plf, pli
 */
{
  if (is_void(top)) top= bytscl([0.,1.])(2);  /* palette size - 1 */
  top= long(top);
  if (top<0 | top>255) error, "top value out of range 0-255";
  y= z(*);
  if (!is_void(cmin)) y= y(where(y>=cmin));
  if (!is_void(cmax)) y= y(where(y<=cmax));
  y= sedgesort(y);
  x= span(0.,1., numberof(y));
  xp= span(0.,1., top+2);
  bins= interp(y, x, xp);
  list= where(bins(dif)<=0.0);
  if (numberof(list)) {
    /* some value (or values) of z are repeated many times --
       try to handle this by adding a small slope to the sorted y */
    dy= y(0)-y(1);
    if (!dy) dy= 1.0;
    for (eps=1.e-10 ; eps<1000.1 ; eps*=10.) {
      bins= interp(y+eps*dy*x, x, xp);
      list= where(bins(dif)<=0.0);
      if (!numberof(list)) break;
    }
    if (eps>1000.) error, "impossible error??";
  }
  return char(max(min(digitize(z,bins)-2,top),0));
}

func set_spydr_ccolor(color)
{
  extern spydr_ccolor;
  
  if (color==spydr_ccolor) return;
  
  spydr_ccolor = color;
  spydr_disp;
}

func set_spydr_mcolor(color)
{
  extern spydr_mcolor;
  
  if (color==spydr_mcolor) return;
  
  spydr_mcolor = color;
  spydr_disp;
}

func set_spydr_clabel(clabel)
{
  extern spydr_clabel;
  
  if (clabel==spydr_clabel) return;
  
  spydr_clabel = clabel;
  spydr_disp;
}

func disp_contours_plus_tv(void)
// coutour plot + pli for main window
{
  disp_tv;
  disp_contours,nofma=1;
}


func disp_surface(void)
// surface plot for main window
{
  extern surface_init,surf_subim;

  require,"plwf.i";
  //  require,"pl3d.i";

  if (spydr_nim<1) return;
  
  window,spydr_wins(1);
  
  local max_dim;
  max_dim=256;
  
  if (surface_init) {
    surf_subim = get_subim();
    if (anyof(dimsof(surf_subim)(2:3)>max_dim)) {
      maxfact = max(dimsof(surf_subim)(2:3)/float(max_dim));
      final_dim = long(dimsof(surf_subim)(2:3)/maxfact);
      surf_subim = bilinear(surf_subim,final_dim(1),final_dim(2));
    }
  }
  orient3,spydr_azimuth*pi/180.,spydr_elevation*(pi/180.);
  light3, diffuse=.5, specular=1., sdir=[1,.5,1];
  xy = indices(dimsof(surf_subim));
  fma;
  if (spydr_shades) {
    plwf,clip(surf_subim,cmin,cmax),xy(,,2),xy(,,1),edges=0,shade=1;
  } else {
    plwf,clip(surf_subim,cmin,cmax),xy(,,2),xy(,,1);
  }
  if (surface_init) limits;
  surface_init=0;
}


func spydr_pltitle(title)
// pltitle adapted for spydr
{
  plth_save = pltitle_height;
  pltitle_height = long(pltitle_height*spydr_defaultdpi/83.);
  
  port= viewport();
  if (current_window()==spydr_wins(1)) plth=pltitle_height;
  else plth=long(pltitle_height*0.85);
  plt, escapechar(title), port(zcen:1:2)(1), port(4)+0.005,
    font=pltitle_font, justify="CB", height=plth;

  pltitle_height = plth_save;
}


func spydr_xytitles(xtitle,ytitle,adjust)
// xytitles adapted for spydr
{
  plth_save = pltitle_height;
  pltitle_height = long(pltitle_height*spydr_defaultdpi/83.);
  
  curw=current_window();
  if (curw==spydr_wins(3)) pltitle_height=long(pltitle_height*0.8);
  if (adjust==[]) {
    if (curw==spydr_wins(1)) adjust = xytitles_adjust1;
    if (curw==spydr_wins(3)) adjust = xytitles_adjust3;
  }
  xytitles,escapechar(xtitle),escapechar(ytitle),adjust;

  pltitle_height = plth_save;
}


func spydr_set_lut(lut)
// change the LookUp Table and Intensity Transfer Table
{
  require,"idl-colors.i";
  extern rlut,glut,blut,spydr_lut;
  local r,g,b;

  window,spydr_wins(1);
  if (lut) spydr_lut = lut;
  
  if (lut!=[]) {  // then read and set new lut
    if (lut==0) palette,"earth.gp";
    else loadct,lut;
    palette,query=1,rlut,glut,blut;  // store
  }

  // invert?
  if (spydr_invertlut) {
    r=rlut(::-1); g=glut(::-1); b=blut(::-1);
  } else {
    r=rlut; g=glut; b=blut;
  }

  // itt:
  if (spydr_itt<=1) { // linear
    ind = span(0.,1.,spydr_ncolors);
  } else if (spydr_itt==2) { // sqrt
    ind = sqrt(span(0.,1.,spydr_ncolors));
  } else if (spydr_itt==3) { // square
    ind = (span(0.,1.,spydr_ncolors))^2.;
  } else if (spydr_itt==4) { // log
    ind = log10(span(10.^(-spydr_log_itt_dex),1.,spydr_ncolors)); // 8 dex
    ind -= min(ind);
    ind /= max(ind);
  } else if (spydr_itt>=5) { // histeq
    ind = span(0.,1.,spydr_ncolors);
  }
  ind = round(ind*(spydr_ncolors-1)+1);
  r = r(ind); g = g(ind); b = b(ind);

  // and finally, load the palette:
  for (i=1;i<=3;i++) {
    window,spydr_wins(i);
    palette,r,g,b;
  }
  spydr_disp;
}


func disp_cpc(e)
{
  extern cmin,cmax,imnum,spydrs,gui_realized;

  if (spydr_nim<1) return;

  if (x2==x1) subim = spydr_im; // init, not defined
  else subim=get_subim(x1,x2,y1,y2);
  
  if (e==0) {
    cmin = min(subim);
    cmax = max(subim);
  } else {
    tmp = minmax(cpc(subim,0.1,0.999));
    cmin = tmp(1);
    cmax = tmp(2);
  }
  spydrs(imnum).cmin = cmin;
  spydrs(imnum).cmax = cmax;
  if (gui_realized)                                                     \
    spydr_pyk,swrite(format="y_set_cmincmax(%f,%f,%f,1)",float(cmin),float(cmax),float(cmax-cmin)/100.);  
}


func rad4zoom_incr(void) { rad4zoom=min(rad4zoom+1,spydrs(imnum).dims(2)/2); }
func rad4zoom_decr(void) { rad4zoom=max(rad4zoom-1,0); }


//=================================
// PLOT functions
//=================================

func spydr_compute_distance(zero)
{
  extern zero_coord;
  if ((zero)||(zero_coord==[])) {
    zero_coord = current_mouse(spydr_wins(1));
    spydr_pyk_status_push,swrite(format="coordinates = (%.2f,%.2f)",zero_coord(1),zero_coord(2));
    return;
  }
  coord = current_mouse(spydr_wins(1));
  if (coord==[]) return;
  if (zero_coord==[]) return;
  dis = abs(coord(1)-zero_coord(1),coord(2)-zero_coord(2));
  spydr_pyk_status_push,swrite(format="coordinates = (%.2f,%.2f), dist. to ref = %.2f pixels = %.3f \"",\
                               coord(1),coord(2),dis,dis*spydrs(imnum).pixsize);

}

func show_lower_gui(visibility)
{
  spydr_pyk,swrite(format="glade.get_widget('togglelower').set_active(%d)",visibility(1));
}

func plot_cut(void)
{
  extern onedx,onedy;
  
  curw = current_window();
  window,spydr_wins(1);
  spydr_pyk_status_push,"Click and drag over desired cut";
  m=mouse(1,2,"Click and drag over desired cut");
  spydr_pyk_status_push,"";
  if (spydr_plot_in_arcsec) m(1:4)=spydr_arcsec_to_pixels(m(1:4));
  x1=m(1); y1=m(2);
  x2=m(3); y2=m(4);
  d = abs(x2-x1,y2-y1);
  x = span(x1,x2,long(ceil(d)));
  y = span(y1,y2,long(ceil(d)));
  cut_y = spline2(spydr_im,x,y);
  cut_x = sqrt( (x-x1)^2. + (y-y1)^2.);
  if (spydr_plot_in_arcsec) {
    if (spydr_check_pixsize()) return;
    cut_x *= spydrs(imnum).pixsize;
    xtit = "arcsec";
  } else xtit="pixels";
  
  show_lower_gui,1;
  
  window,spydr_wins(3);
  fma;
  plh,cut_y,cut_x;
  limits,square=0; limits;
  spydr_xytitles,xtit,"value";
  spydr_pltitle,swrite(format="[%.1f,%.1f] to [%.1f,%.1f]",x1,y1,x2,y2);
  limits;
  //  plmargin,0.02;
  window,curw;
  onedx=cut_x;
  onedy=cut_y;
}


func plot_xcut(j)
{
  extern onedx,onedy;

  if (spydr_nim<1) return;

  if (spydr_plot_in_arcsec) {
    if (spydr_check_pixsize()) return;
    fact = spydrs(imnum).pixsize;
    xtit = "arcsec";
  } else {
    fact = 1.0f;
    xtit="pixels";
  }
  
  if (j==[]) {
    cur=get_cursor();
    if (cur==[]) return;
    j = cur(2)
  }
  get_subim,i1,i2,j1,j2;
  curw = current_window();

  show_lower_gui,1;
  
  window,spydr_wins(3);
  fma;
  cut_y=spydr_im(,j);
  cut_x=indgen(spydrs(imnum).dims(2))*fact;
  plh,cut_y,cut_x;
  spydr_xytitles,xtit,"value";
  spydr_pltitle,swrite(format="line# %d",j);
  limits,i1*fact,i2*fact;
  window,curw;
  onedx=cut_x;
  onedy=cut_y;
}


func plot_ycut(i)
{
  extern onedx,onedy;
  
  if (spydr_nim<1) return;

  if (spydr_plot_in_arcsec) {
    if (spydr_check_pixsize()) return;
    fact = spydrs(imnum).pixsize;
    xtit = "arcsec";
  } else {
    fact = 1.0f;
    xtit="pixels";
  }
  
  if (i==[]) {
    cur=get_cursor();
    if (cur==[]) return;
    i = cur(1)
  }
  get_subim,i1,i2,j1,j2;
  curw = current_window();
  
  show_lower_gui,1;
  
  window,spydr_wins(3);
  fma;
  cut_y=spydr_im(i,);
  cut_x=indgen(spydrs(imnum).dims(3))*fact;
  plh,cut_y,cut_x;
  spydr_xytitles,xtit,"value";
  spydr_pltitle,swrite(format="column# %d",i);
  limits,j1*fact,j2*fact;
  window,curw;
  onedx=cut_x;
  onedy=cut_y;
}


func fit_gaussian_1d(void)
{
  extern onedx,onedy;
  local units;

  if (noneof(onedy)) spydr_pyk_status_push,"Nothing to fit";
  if (numberof(onedy)!=numberof(onedx)) \
    spydr_pyk_status_push,"onedy and onedx do not have the same dimensions!";
  
  a = [0.,max(onedy),onedx(wheremax(onedy)),3.];
  clmfit,onedy,onedx,a,"a(1)+a(2)*exp(-0.5*((x-a(3))/a(4))^2.)",yfit;
  a(4)=abs(a(4));
  curw = current_window();
  window,spydr_wins(3);
  plh,yfit,onedx,color="red";
  window,curw;
  //  if (spydr_plot_in_arcsec) units="arcsec"; else units="pixels";
  units = "";
  spydr_pyk_status_push,swrite(format="gaussian, max=%f @ x=%.3f, sig=%.3f%s (fwhm=%.3f), background=%f",\
                               a(2),a(3),a(4),units,a(4)*2.355,a(1));
}


func plot_radial(void)
{
  if (spydr_nim<1) return;
  
  cur=get_cursor();
  subim=get_subim(i1,i2,j1,j2);
  curw = current_window();
  
  show_lower_gui,1;

  window,spydr_wins(3);
  xy = indices(dimsof(subim))-(cur(1:2)-[i1,j1]+1)(-,-,);
  d = abs(xy(,,1),xy(,,2));
  fma;
  if (spydr_plot_in_arcsec) {
    if (spydr_check_pixsize()) return;
    fact = spydrs(imnum).pixsize;
    xtit = "arcsec";
  } else {
    fact = 1.0f;
    xtit="pixels";
  }
  plp,subim,d*fact,symbol=default_symbol,size=0.3;
  spydr_xytitles,xtit,"value";
  limits;
  plmargin,0.02;
  window,curw;
}


func plot_histo(void)
{
  extern onedx,onedy;
  
  if (spydr_nim<1) return;

  subim=get_subim(x1,x2,y1,y2);  //must be in window,1 when doing that.
  
  if (!spydr_histnbins) spydr_histnbins=100;
  if (spydr_histbinsize==0) binsize=(cmax-cmin)/spydr_histnbins;
  else binsize = spydr_histbinsize;
  
  hy = histo2(subim(*),hx,binsize=binsize,binmin=cmin,binmax=cmax);
  curw = current_window();

  show_lower_gui,1;

  window,spydr_wins(3);
  fma;
  plh,hy,hx;
  //  plmargin,0.02;
  spydr_pltitle,swrite(format="%s: histogram of region [%d:%d,%d:%d]",spydrs(imnum).name,x1,x2,y1,y2);
  spydr_pyk_status_push,swrite(format=" %s: avg=%4.7g | med=%4.7g | rms=%4.7g",
                         spydrs(imnum).name,avg(subim),sedgemedian(subim(*)),subim(*)(rms));
  spydr_xytitles,"value","number in bin";
  limits;
  window,curw;
  onedx = hx;
  onedy = hy;
}


func do_limits(void)
{
  curw = current_window();
  window,spydr_wins(3);
  limits,square=0;
  limits;
  window,curw;
}


//============================
// Convenience Functions
//============================

func spydr_exportjpeg(name)
{
  extern spydr_savedir;

  if ((strpart(name,-3:0)!=".jpg")&&(strpart(name,-4:0)!=".jpeg")) name+=".jpg";
  
  spydrs(imnum).saveasname = basename(name);
  spydr_savedir = dirname(name);
  
  jpeg,name;
  write,format="Image exported to %s\n",name;
  spydr_pyk_status_push,swrite(format="Image exported to %s",name);
}

func spydr_exportpng(name)
{
  extern spydr_savedir;

  if (strpart(name,-3:0)!=".png") name+=".png";
  
  spydrs(imnum).saveasname = basename(name);
  spydr_savedir = dirname(name);
  
  png,name;
  write,format="Image exported to %s\n",name;
  spydr_pyk_status_push,swrite(format="Image exported to %s",name);
}

func spydr_exportpdf(name)
{
  extern spydr_savedir;

  if (strpart(name,-3:0)!=".pdf") name+=".pdf";
  
  spydrs(imnum).saveasname = basename(name);
  spydr_savedir = dirname(name);
  
  pdf,name;
  write,format="Image exported to %s\n",name;
  spydr_pyk_status_push,swrite(format="Image exported to %s",name);
}

func spydr_exportps(name)
{
  extern spydr_savedir;

  if (strpart(name,-2:0)==".ps") name=strpart(name,1:-3);
  
  spydrs(imnum).saveasname = basename(name);
  spydr_savedir = dirname(name);
  
  hcps,name;
  write,format="Image exported to %s.ps\n",name;
  spydr_pyk_status_push,swrite(format="Image exported to %s.ps",name);
}

func spydr_exporteps(name)
{
  extern spydr_savedir;
  if (strpart(name,-3:0)==".eps") name=strpart(name,1:-4);
  
  spydrs(imnum).saveasname = basename(name);
  spydr_savedir = dirname(name);
  
  eps,name;
  write,format="Image exported to %s.eps\n",name;
  spydr_pyk_status_push,swrite(format="Image exported to %s.eps",name);
}


func spydr_save(void)
{
  extern spydr_savedir;
  name = spydr_savedir+"/"+escapechar2save(spydrs(imnum).saveasname);
  if (strpart(name,-4:0) != ".fits") name+=".fits";
  //  fits_write,name,*spydrs(imnum).pim,overwrite=1;
  fits_write,name,spydr_im,overwrite=1;
  write,format="Image saved in %s\n",name;
  spydr_pyk_status_push,swrite(format="Image saved in %s",name);
}

func spydr_saveas(name)
{
  extern spydr_savedir;

  if (strpart(name,-4:0) != ".fits") name+=".fits";
  
  spydrs(imnum).saveasname = basename(name);
  spydr_savedir = dirname(name);
  fits_write,name,*spydrs(imnum).pim,overwrite=1;
  write,format="Image saved in %s\n",name;
  spydr_pyk_status_push,swrite(format="Image saved in %s",name);
}

func escapechar2save(s)
{
  s=streplace(s,strfind(".fits",s,n=20),"");
  s=streplace(s,strfind("/",s,n=20),":");
  s=streplace(s,strfind(" ",s,n=20),"_");
  return s;
}

//===============================

func spydr_cubeops(opn)
{
  local cube;
  if (spydr_nim<1) return;
  
  if (nallof(spydrs.dims==spydrs(1).dims)) {
    spydr_pyk_error,"cubeops: all images must have the same size";
    return;
  }
  spydr_pyk,"set_cursor_busy(1)";
  spydr_pyk_status_push,"Processing cube operation, please wait...";
  cube = array(float,_(3,spydrs(1).dims(2:3),spydr_nim));
  for (i=1;i<=spydr_nim;i++) cube(,,i) = *spydrs(i).pim;
  cube = cube(,,where(spydrs.space!="results"));
  if (opn==1) {
    res = median(cube,3);
    spydr,res,append=1,name="cube median";
  } else if (opn==2) {
    res = cube(,,avg);
    spydr,res,append=1,name="cube average";
  } else if (opn==3) {
    res = cube(,,sum);
    spydr,res,append=1,name="cube sum";
  } else if (opn==4) {
    res = cube(,,rms);
    spydr,res,append=1,name="cube rms";
  }
  spydrs(0).space="results";
  cube=[];
  spydr_pyk,"set_cursor_busy(0)";
  spydr_pyk_status_push,"Processing cube operation: Done.";
}


func spydr_rebin(fact2)
// rebin the image by 2,3,4
{
  extern spydr_im,cur_limits,rebin_init,rebin_fact,rebin_stamp;

  window,spydr_wins(1);

  fact = 2.^fact2;

  if (fact==rebin_fact) return;
  
  //  if (fact==1) {
  //    spydr_im = *spydrs(imnum).pim;
  //    spydrs(imnum).pixsize = spydrs(imnum).opixsize;
  //    spydrs(imnum).dims = dimsof(spydr_im); // update dims
  //    rebin_fact=1;
  //    return;
  //  }
  
  spydr_im=*spydrs(imnum).pim;

  if (fact>1) {
    spydr_im = spline2(spydr_im,fact); // interpolate
  } else if (fact<1) {
    for (i=-1;i>=fact2;i--) {
      newdims = dimsof(spydr_im)/2*2;
      spydr_im = bin2(spydr_im(1:newdims(2),1:newdims(3)))/4.;
    }
  }
  spydrs(imnum).dims = dimsof(spydr_im); // update dims
  // set news limits so that area displayed is unchanged:
  if (!spydr_plot_in_arcsec) {
    these_limits = limits();
    these_limits(1:4) /= rebin_fact; // what were the real limits with previous fact
    limits,_(these_limits(1:4)*fact,these_limits(5));
  }
  rebin_fact = fact; // keep for next rebin
  spydrs(imnum).pixsize = spydrs(imnum).opixsize/fact;
  spydr_pyk,swrite(format="y_parm_update('pixsize',%f)",float(spydrs(imnum).pixsize));
}


func get_subim(&x1,&x2,&y1,&y2)
{
  if (spydr_nim<1) return;
  curw = current_window();
  window,spydr_wins(1);
  lim=limits();
  if (spydr_plot_in_arcsec) lim(1:4) = spydr_arcsec_to_pixels(lim(1:4));
  x1=round(clip(lim(1),1,spydrs(imnum).dims(2)));
  x2=round(clip(lim(2),1,spydrs(imnum).dims(2)));
  y1=round(clip(lim(3),1,spydrs(imnum).dims(3)));
  y2=round(clip(lim(4),1,spydrs(imnum).dims(3)));
  if ( (x1==x2) || (y1==y2) ) {
    spydr_pyk_error,"Nothing to show";
    error,"Nothing to show";
  }
  window,curw;
  return spydr_im(x1:x2,y1:y2)
}


func toggle_xcut(void) {
  extern xcut, ycut;
  ycut=0;
  xcut = 1-xcut;
  if (xcut) plot_xcut;
  if (xcut) spydr_pyk_status_push,"\"X\" again to stop continuous X cuts";
  else spydr_pyk_status_push,"";
}


func toggle_ycut(void) {
  extern xcut, ycut;
  xcut=0;
  ycut = 1-ycut;
  if (ycut) plot_ycut;
  if (ycut) spydr_pyk_status_push,"\"Y\" again to stop continuous Y cuts";
  else spydr_pyk_status_push,"";
}


func toggle_animate(state)
{
  plsys,1;
  if (state==0) fma;
  if (state!=[]) animate,state; else animate;
}


func gui_update(void)
{
  extern spydrs,imnum,spydr_lut;
  extern first_update;

  if (imnum==[]) return; // GUI open but no image
  
  spydr_pyk,swrite(format="window.set_title('spydr - %s')",spydrs(imnum).name); 
  spydr_pyk,swrite(format="current_image_saveas_name = '%s'",escapechar2save(spydrs(imnum).saveasname)); 
  spydr_pyk,swrite(format="y_parm_update('binsize',%f)",float(spydr_histbinsize));
  spydr_pyk,swrite(format="y_parm_update('nlevs',%d)",long(spydr_nlevs));
  spydr_pyk,swrite(format="y_parm_update('pixsize',%f)",float(spydrs(imnum).pixsize));
  spydr_pyk,swrite(format="y_parm_update('boxsize',%d)",long(spydr_boxsize));
  spydr_pyk,swrite(format="y_parm_update('saturation',%f)",float(spydr_saturation));
  spydr_pyk,swrite(format="y_parm_update('airmass',%f)",float(spydr_airmass));
  spydr_pyk,swrite(format="y_parm_update('wavelength',%f)",float(spydrs(imnum).wavelength));
  spydr_pyk,swrite(format="y_parm_update('teldiam',%f)",float(spydr_teldiam));
  spydr_pyk,swrite(format="y_parm_update('zero_point',%f)",float(spydr_zero_point));
  spydr_pyk,swrite(format="y_parm_update('cobs',%f)",float(spydr_cobs));
  spydr_pyk,swrite(format="y_parm_update('strehl_aper_radius',%f)",float(spydr_strehlmask));
  spydr_pyk,swrite(format="y_set_checkbutton('compute_strehl',%d)",long(compute_strehl));
  spydr_pyk,swrite(format="glade.get_widget('plugins').set_active(%d)",spydr_showplugins);
  spydr_pyk,swrite(format="y_set_checkbutton('output_magnitudes',%d)",long(output_magnitudes));
  spydr_pyk,swrite(format="y_set_cmincmax(%f,%f,%f,0)",float(cmin),float(cmax),float(cmax-cmin)/100.);
  spydr_pyk,swrite(format="y_set_lut(%d)",spydr_lut);
  spydr_pyk,swrite(format="y_set_invertlut(%d)",spydr_invertlut);
  spydr_pyk,swrite(format="y_set_itt(%d)",clip(long(spydr_itt-1),0,4));
  if (first_update==[]) {
    spydr_pyk,swrite(format="currentsavedir = '%s'",spydr_savedir); 
    spydr_pyk,"glade.get_widget('menubar_images').set_sensitive(1)";
    spydr_pyk,"glade.get_widget('menubar_ops').set_sensitive(1)";
    spydr_pyk,"glade.get_widget('save').set_sensitive(1)";
    spydr_pyk,"glade.get_widget('export').set_sensitive(1)";
    spydr_pyk,"glade.get_widget('saveas').set_sensitive(1)";
    spydr_pyk,swrite(format="glade.get_widget('debug').set_active(%d)",pyk_debug);
    spydr_pyk,swrite(format="glade.get_widget('plot_in_arcsec').set_active(%d)",spydr_plot_in_arcsec);
    spydr_pyk,swrite(format="glade.get_widget('cmincmax').set_active(%d)",zoom_cmincmax);
    //    spydr_pyk,swrite(format="glade.get_widget('%s').set_active(1)",spydr_ccolor);
    first_update=1;
  }
  sync_view_menu;
}


func imchange_update(void)
{
  extern imnum,cmin,cmax;
  
  spydr_pyk,swrite(format="y_parm_update('pixsize',%f)",float(spydrs(imnum).pixsize));
  spydr_pyk,swrite(format="y_parm_update('wavelength',%f)",float(spydrs(imnum).wavelength));
  spydr_pyk,swrite(format="y_parm_update('zero_point',%f)",float(spydr_zero_point));
  spydr_pyk,swrite(format="y_set_cmincmax(%f,%f,%f,0)",float(cmin),float(cmax),float(cmax-cmin)/100.);
}


//==============================
// ZOOM, cursor and misc graphic
//==============================

prevxy = [0,0];

func get_cursor(wid)
/* DOCUMENT get_cursor(wid)
   returns [xpos,ypos]
   where xpos,ypos is the cursor x and y coordinates
   Returns [] if not in correct window;
   SEE ALSO:
 */
{
  if (wid==[]) wid=spydr_wins(1);
  cur = current_mouse(wid);
  if (cur==[]) return;
  if (spydr_plot_in_arcsec) {
    // return in pixels
    if (spydr_check_pixsize()) return;
    cur(1:2) = spydr_arcsec_to_pixels(cur(1:2));
  } else {
    cur(1:2) = cur(1:2)+1; //ceil
  }
  cur = long(cur);
  return cur;
}
  

stop_zoom=0;
func spydr_clean(void)
{
  extern spydrs,imnum;
  extern spydr_im,cmin,cmax;
  extern spydr_fh,x1,x2,y1,y2;
  extern imnamen,spydr_nim,xcut,ycut;
  
  spydr_get_available_windows;
  imnamen=spydr_nim=xcut=ycut=0;
  stop_zoom=1;
  spydrs=spydr_im=imnum=spydr_fh=x1=x2=y1=y2=[];
}

func spydr_check_pixsize(void)
{
  if (spydrs(imnum).pixsize==0) {
    spydr_pyk_error,"Coordinates requested in arcsec but pixsize is 0!";
    return 1;
  } else return 0;
}

func spydr_set_plot_in_arcsec(flag)
{
  extern spydr_plot_in_arcsec;
  if (flag) if (spydr_check_pixsize()) return;
  spydr_plot_in_arcsec = flag;
  spydr_disp;
  unzoom;
  limits;
}

func spydr_arcsec_to_pixels(arcsec)
{
  if (spydr_check_pixsize()) return;
  
  return long(arcsec/spydrs(imnum).pixsize)+1;
}

func disp_zoom(once=)
{
  extern from_disp,stop_zoom,from_imnum;

  if (stop_zoom) {
    stop_zoom=0;
    return;
  }

  cur = get_cursor();
  
  if ( (cur==[]) || (from_disp==3) ) { // not in correct window
    if (!once) after,0.05,disp_zoom;
    return;
  }

  if ((from_imnum==[])||(from_imnum==imnum)) {
    if (allof(prevxy==cur(1:2)) && (prevz==rad4zoom)) {  // same positon as before
      if (!once) after,0.05,disp_zoom;
      return;
    }
  }
  from_imnum=imnum;

  sys = cur(3);
  if (sys!=0) {
    
    i = clip(cur(1),1,spydrs(imnum).dims(2));
    j = clip(cur(2),1,spydrs(imnum).dims(3));
    spydr_pyk,swrite(format="y_set_xyz('%d','%d','%4.7g')",\
               i,j,float(spydr_im(i,j)));

    local_rad=min([5,rad4zoom]);
    x1 = clip(i-local_rad,1,spydrs(imnum).dims(2));
    x2 = clip(i+local_rad,1,spydrs(imnum).dims(2));
    y1 = clip(j-local_rad,1,spydrs(imnum).dims(3));
    y2 = clip(j+local_rad,1,spydrs(imnum).dims(3));
    spydr_pyk,swrite(format="y_text_parm_update('localmax','%4.7g')",\
               float(max(spydr_im(x1:x2,y1:y2))));
    sim=spydr_im(x1:x2,y1:y2);
    wm = where2(sim==max(sim))(,1)-local_rad-1;

    if ((i-local_rad)<1) wm(1) += (1-i+local_rad);
    if ((j-local_rad)<1) wm(2) += (1-j+local_rad);

    // FIXME: blue cursor is not at correct position when pointing lower than smaller indice

    x1 = i-rad4zoom;
    x2 = i+rad4zoom;
    y1 = j-rad4zoom;
    y2 = j+rad4zoom;
    
    if (x1<1) { x1=1; x2=2*rad4zoom+1; }
    else if (x2>spydrs(imnum).dims(2)) { x2=spydrs(imnum).dims(2); x1=x2-2*rad4zoom; }      

    if (y1<1) { y1=1; y2=2*rad4zoom+1; }
    else if (y2>spydrs(imnum).dims(3)) { y2=spydrs(imnum).dims(3); y1=y2-2*rad4zoom; }      

    window,spydr_wins(2);
    fma;
    if (zoom_cmincmax) {
      //pli,bytscl(spydr_im(x1:x2,y1:y2),cmin=cmin,cmax=cmax);
      pli,spydr_imd(x1:x2,y1:y2),2*rad4zoom+1,2*rad4zoom+1;
    } else pli,spydr_im(x1:x2,y1:y2),2*rad4zoom+1,2*rad4zoom+1;
    //    limits,0,2*rad4zoom+1,0,2*rad4zoom+1;
    limits;
    // plot local maxima location
    plp,j-y1+wm(2)+0.5,i-x1+wm(1)+0.5,symbol=2,color="blue",width=1;
    // plot cursor location
    plp,j-y1+0.5,i-x1+0.5,symbol=2,color="red",width=3;

    // x and y cuts
    if (xcut) {
      plot_xcut,j;
    } else if (ycut) {
      plot_ycut,i;
    }

    window,spydr_wins(1);
  }
  prevxy = cur(1:2);
  prevz = rad4zoom;
  if (!once) after,0.05,disp_zoom;
}


func escapechar(s)
{
  s=streplace(s,strfind("_",s,n=20),"!_");
  s=streplace(s,strfind("^",s,n=20),"!^");
  return s;
}


func spydr_shortcut_help(void)
{
  help_text = ["<span font_family=\"monospace\">",
               "The following shortcuts are available:",
               " x/y: Plot line/column under cursor",
               " X/Y: Toggle continuous plot of line/column",
               "       under cursor",
               " c:   Interactive plot of cut across image",
               " h:   Plot histogram of <b>visible region</b>",
               " r:   Radial plot centered on cursor",
               " f:   Fit 1d gaussian to 1d plot",
               " e:   Adjust min and max cut to 10% and 99.9% ","      of distribution of <b>visible region</b>",
               " E:   Reset min and max cut to min and max ","      of <b>visible region</b>",
               " n/p: Next/prevous image",
               " d:   Delete current image from stack",
               " s:   Sigma filter displayed image",
               " M:   Mark coordinate zero point (see m)",
               " m:   Compute distance to coordinate zero point",
               " -/+: Decrease/Increase zoom factor in zoom window",
               " u:   Unzoom",
               " ?:   This help","</span>"];
  write,format="%s\n",help_text(2:-1);
  spydr_pyk_info_w_markup,help_text;
}


func strehl_convert(sfrom,wfrom,wto)
{
  return exp(wfrom^2.*log(sfrom)/wto^2.)
}


func set_imnum(nn,from_python,force=)
{
  extern spydrs,imnum,rebin_fact;
  extern spydr_im,cmin,cmax;
  extern gui_realized;

  //write,format="YORICK: Request for set_imnum %d\n",nn;
  
  if ((nn==imnum)&&(!force)) return;
  if (nn>spydr_nim) return;
  
  imnum = nn;
  spydr_im = *(spydrs(imnum).pim);
  spydrs(imnum).dims = dimsof(spydr_im);
  spydrs(imnum).pixsize = spydrs(imnum).opixsize;
  rebin_fact=1;
  
  if ((spydrs(imnum).cmin==0)&(spydrs(imnum).cmax==0)) disp_cpc,1;
  else {
    cmin = spydrs(imnum).cmin;
    cmax = spydrs(imnum).cmax;
  }
  if ((from_python==[])&&(gui_realized)) {
    spydr_pyk,swrite(format="set_imnum(%d,%d,%d)",nn,spydr_nim,(spydr_nim>1));
  }
  if (gui_realized) {
    spydr_pyk,swrite(format="window.set_title('spydr - %s')",spydrs(nn).name); 
    spydr_pyk,swrite(format="current_image_saveas_name = '%s'",escapechar2save(spydrs(imnum).saveasname));
  }
}

func spydr_redisp(void)
{
  extern spydrs,imnum,spydr_im;
  
  spydr_im = *(spydrs(imnum).pim);
  spydr_disp;
}

func set_cmin(pycmin)
{
  extern spydrs,cmin,imnum;
  //  write,format="pycmin=%f, cmin=%f\n",pycmin,cmin;
  // because the precision was cut by the yorick -> python -> yoric
  // transfer, we have to allow for some slack
  if ((cmax-cmin)!=0) if ((abs(pycmin-cmin)/(cmax-cmin))<1e-3) return;
  if (pycmin>cmax) {
    spydr_pyk_status_push,"cmin > cmax, ignoring";
    return;
  }
  cmin = spydrs(imnum).cmin = pycmin;
  spydr_disp;
}

func set_cmax(pycmax)
{
  extern spydrs,cmax,imnum;
  //  write,format="pycmax=%f, cmax=%f\n",pycmax,cmax;
  // because the precision was cut by the yorick -> python -> yoric
  // transfer, we have to allow for some slack
  if ((cmax-cmin)==0) if ((abs(pycmax-cmax)/(cmax-cmin))<1e-3) return;
  if (pycmax<cmin) {
    spydr_pyk_status_push,"cmax < cmin, ignoring";
    return;
  }
  cmax = spydrs(imnum).cmax = pycmax;
  spydr_disp;
}

func spydr_sigmafilter(void)
{
  if (spydr_nim<1) return;
  subim = get_subim(x1,x2,y1,y2);
  subim = sigmaFilter(subim,spydr_sigmafilter_nsig,iter=3,silent=1);
  spydr_im(x1:x2,y1:y2) = subim;
  spydr_disp;
}

//=========================
// Initial I/O
//=========================

func spydr_fits_read(imname,&fh,hdu=)
{
  extern warning_done;  

  write,format="\r Reading %s",imname;

  if (hdu) {
    im = fits_read(imname,fh,hdu=hdu);
  } else {
    im = fits_read(imname,fh);
    if (numberof(im)==0) {
      // try next hdu (e.g. niri)
      im = fits_read(imname,fh,hdu=2);
    }
  }
  
  if (numberof(im)==0) {
    spydr_pyk_error,imname+"found, but no data";
    error,imname+"found, but no data";
  }

  if (fits_get(fh,"INSTRUME")=="NICI") {
    // SPECIAL NICI !!!!!!
    // all NICI specialized commands in here, please.
    if (!warning_done) {
      write,"\n>>>>>>>  im=im-im(,::-1)  <<< SPECIAL NICI !!!\n";
      warning_done=1;
    }
    im = im-im(,::-1);
    extern nici_array;
    grow,nici_array,(fits_get(fh,"CBFW")?"watson":"holmes");
  }
  
  return im;
}


func figure_image_wavelength(fh)
// as per the nici filter page
// http://www.gemini.edu/sciops/instruments/nici/niciIndex.html
{
  wavl = spydr_wavelength;
  if (fits_get(fh,"INSTRUME")=="NICI") {
    if (anyof("CBFW"==fits_get_keywords(fh))) wav = fits_get(fh,"CBFW");
    else if (anyof("CRFW"==fits_get_keywords(fh))) wav = fits_get(fh,"CRFW");
    else if (anyof("FILTER_B"==fits_get_keywords(fh))) wav = fits_get(fh,"FILTER_B");
    else if (anyof("FILTER_R"==fits_get_keywords(fh))) wav = fits_get(fh,"FILTER_R");
    else return wavl;
    if (wav=="CH4-H1%S") wavl=1.587;
    if (wav=="CH4-H1%Sp") wavl=1.603;
    if (wav=="J") wavl=1.25;
    if (wav=="H") wavl=1.65;
    if (wav=="K") wavl=2.20;
    if (wav=="Ks") wavl=2.15;
    if (wav=="FeII") wavl=1.644;
    if (wav=="H2-1-0-S1") wavl=2.1239;
    if (wav=="BrGamma") wavl=2.1286;
    if (wav=="Kcont") wavl=2.2718;
    if (wav=="CH4-H4%S") wavl=1.578; // was 1.596
    if (wav=="CH4-H4%L") wavl=1.653; // was 1.701
    //
    if (wav=="CH4-H4%S_G0000") wavl=1.578;   // TBC
    if (wav=="CH4-H4%L_G0000") wavl=1.653;   // TBC
    if (wav=="CH4-H1%S_G0000") wavl=1.587;   // TBC
    if (wav=="CH4-H1%Sp_G0000") wavl=1.603;   // TBC
    if (wav=="CH4-H4%S_G0743") wavl=1.578;
  }
  return wavl;
}


func spydr_set_pixsize(value)
{
  extern spydrs,imnum;

  spydrs(imnum).pixsize = value;
}


func spydr_set_wavelength(value)
{
  extern spydrs,imnum;

  spydrs(imnum).wavelength = value;
}


func figure_image_pixsize(fh)
{
  pixsize = spydr_pixsize;
  if (fits_get(fh,"INSTRUME")=="NICI") return 0.018;
  else return pixsize;
}

func spydr_delete_current_from_stack(void)
{
  extern spydrs,imnum,spydr_nim;
  if ((imnum)&&(spydr_nim)) {
    if (spydr_nim==1) {
      spydrs=[];
      spydr_nim=0;
      window,spydr_wins(1);
      fma; redraw;
    } else {
      if (imnum==1) {
        spydrs=spydrs(2:);
        nn=imnum;
      } else if (imnum==spydr_nim) {
        spydrs=spydrs(1:-1);
        nn=imnum-1;
      } else {
        spydrs=_(spydrs(1:imnum-1),spydrs(imnum+1:0));
        nn=imnum;
      }
      spydr_nim--;
      set_imnum,nn,force=1;
      spydr_disp;
    }
    sync_view_menu;
  }
}

func spydr_get_available_windows(void)
/* DOCUMENT spydr_get_available_windows(void)
   Intended to probe for available windows # not to
   interfere with regular session.
   I have no way to do that right now, so imposing
   high numbers, hopefully not used.
   SEE ALSO:
 */
{
  extern spydr_wins;
  // main, zoom, plot windows
  if (allof(spydr_wins==0)) spydr_wins = [40,41,42];
}

func spydr_pyk_flush(void)
{
  extern flushing;
  if (_spydr_pyk_proc==[]) {
    flushing=0;
    return;
  }
  flushing=1;
  spydr_pyk,"yo2py_flush";
  after,flushing_interval,spydr_pyk_flush;
}
flushing=0;

func parse_flags(args)
{
  extern spydr_dpi, spydr_conffile, pyk_debug, spydr_itt;
  extern spydr_invertlut, spydr_azimuth, spydr_elevation;
  extern spydr_pixsize, spydr_boxsize, spydr_showplugins;
  extern spydr_saturation, spydr_wavelength, spydr_zero_point;
  extern spydr_histnbins,spydr_strehlmask,spydr_showlower;
  local args,flags;

  if (numberof(args)<4) return;
  
  args = args(4:);
  wflags  = where(!strmatch(args,".fits"));
  wtargets = where(strmatch(args,".fits"));

  if (numberof(wflags)==0) return args; // no flags

  if (numberof(wtargets)>0) targets = args(wtargets);

  flags = args(wflags);

  nflags = numberof(flags);
  valid = array(0,nflags);
  for (i=1;i<=nflags;i++) {
    if ((flags(i)=="--debug")|(flags(i)=="-d")) {
      pyk_debug=1;
      valid(i)=1;
    }
    if ((flags(i)=="--help")|(flags(i)=="-h")) {
      print_help;
    }
    if (flags(i)=="--invert") {
      spydr_invertlut=1;
      valid(i)=1;
    }
    if ((flags(i)=="--fullgui")|(flags(i)=="-g")) {
      spydr_showplugins=1;
      valid(i)=1;
    }
    if ((flags(i)=="--compact")|(flags(i)=="-c")) {
      spydr_showlower=0;
      valid(i)=1;
    }
    if (flags(i)=="--dpi") {
      if (i==nflags) print_help,flags(i);
      spydr_dpi=0;
      sread,flags(i+1),spydr_dpi;
      valid(i:i+1)=1;
    }
    if (flags(i)=="--hdu") {
      if (i==nflags) print_help,flags(i);
      spydr_hdu=0;
      sread,flags(i+1),spydr_hdu;
      valid(i:i+1)=1;
    }
    if (flags(i)=="--itt") {
      if (i==nflags) print_help,flags(i);
      spydr_itt=0;
      sread,flags(i+1),spydr_itt;
      valid(i:i+1)=1;
    }
    if ((flags(i)=="--conf")|(flags(i)=="-f")) {
      if (i==nflags) print_help,flags(i);
      spydr_conffile="";
      sread,flags(i+1),spydr_conffile;
      valid(i:i+1)=1;
    }
    if (flags(i)=="--azimuth") {
      if (i==nflags) print_help,flags(i);
      spydr_azimuth=0;
      sread,flags(i+1),spydr_azimuth;
      valid(i:i+1)=1;
    }
    if (flags(i)=="--elevation") {
      if (i==nflags) print_help,flags(i);
      spydr_elevation=0;
      sread,flags(i+1),spydr_elevation;
      valid(i:i+1)=1;
    }
    if ((flags(i)=="--pixsize")|(flags(i)=="--platescale")|(flags(i)=="-p")) {
      if (i==nflags) print_help,flags(i);
      spydr_pixsize=0.;
      sread,flags(i+1),spydr_pixsize;
      //      spydr_set_pixsize;
      valid(i:i+1)=1;
    }
    if ((flags(i)=="--boxsize")|(flags(i)=="-b")) {
      if (i==nflags) print_help,flags(i);
      spydr_boxsize=0;
      sread,flags(i+1),spydr_boxsize;
      valid(i:i+1)=1;
    }
    if ((flags(i)=="--saturation")|(flags(i)=="-s")) {
      if (i==nflags) print_help,flags(i);
      spydr_saturation=0;
      sread,flags(i+1),spydr_saturation;
      valid(i:i+1)=1;
    }
    if ((flags(i)=="--wavelength")|(flags(i)=="-w")) {
      if (i==nflags) print_help,flags(i);
      spydr_wavelength=0.;
      sread,flags(i+1),spydr_wavelength;
      valid(i:i+1)=1;
    }
    if (flags(i)=="--zeropoint") {
      if (i==nflags) print_help,flags(i);
      spydr_zero_point=0.;
      sread,flags(i+1),spydr_zero_point;
      valid(i:i+1)=1;
    }
    if (flags(i)=="--nbins") {
      if (i==nflags) print_help,flags(i);
      spydr_histnbins=0;
      sread,flags(i+1),spydr_histnbins;
      valid(i:i+1)=1;
    }
    if ((flags(i)=="--strehlmask")|(flags(i)=="-m")) {
      if (i==nflags) print_help,flags(i);
      spydr_strehlmask=0.;
      sread,flags(i+1),spydr_strehlmask;
      valid(i:i+1)=1;
    }
  }
  if (anyof(valid==0)) {
    write,format=" *** ERROR: Unknow flag %s ***\n",flags(where(valid==0)(1));
    print_help;
    if (spydr_context=="called_from_shell") quit;
  }
  return targets;
}

func print_help(field)
{
  if (field) write,format="Syntax error, missing value for %s:\n",field;
  else write,format="%s\n","Syntax error:";
  write,format="%s\n","spydr [--conf conffile --dpi value --itt value --azimuth value --elevation value";
  write,format="%s\n","       --hdu value --pixsize|platescale value --boxsize value --saturation value ";
  write,format="%s\n","       --wavelength value --zeropoint value --nbins value --strehlmask value";
  write,format="%s\n","       --invert --debug --fullgui --compact] image1.fits [image2.fits ...]";
  if (spydr_context=="called_from_shell") quit;
}

func which_spydrconf(void) {
  // look for a possible user's spydr.conf:
  require,"pathfun.i";
  local file,path;
  path1 = pathform(_("./",Y_USER,Y_SITE,"/etc/"));
  file = find_in_path("spydr.conf",takefirst=1,path=path1);
  if (file==[]) {
    path2 = pathform(_("./",Y_USER,Y_SITE)+"share/");
    file = find_in_path("spydr.conf",takefirst=1,path=path2);
  }
  if (file==[]) {
    path3 = pathform(_("./",Y_USER,Y_SITE)+"share/spydr/");
    file = find_in_path("spydr.conf",takefirst=1,path=path3);
  }
  if (file==[]) {
    spydr_pyk_error,swrite(format="Can't find spydr.conf in %s:%s:%s\n",path1,path2,path3);
    error,swrite(format="Can't find spydr.conf in %s:%s:%s\n",path1,path2,path3);
  }
  
  //  write,format=" Using %s\n",file;
  return file;
}

func spydr_quit(void)
{
  extern spydr_context,stop_zoom;
  if (spydr_context=="called_from_shell") {
    quit;
  } else {
    spydr_clean;
    stop_zoom=1;
  } 
}

func add_view_menu(item,ind)
{// unused
  spydr_pyk,swrite(format="add_to_image_menu('%s',%d)",item,ind);
}

func sync_view_menu(void)
{
  spydr_pyk,"reset_image_menu()";
  for (i=1;i<=numberof(spydrs);i++) {
    spydr_pyk,swrite(format="add_to_image_menu('%s',%d)",spydrs(i).name,i);
  }
}


//=======================
// MAIN ROUTINE
//=======================
func spydr(vimage,..,wavelength=,pixsize=,name=,append=,hdu=)
/* DOCUMENT spydr,image
   Software Package in Yorick for Data Reduction
   
   From the command line:
   $ spydr [options] image*.fits cube.fits
   $ yorick -i path_to_spydr/spydr.i image1 image2 ...
   where image can contain wild cards.
   For options, see man page.

   or, within yorick:
   spydr,"image1.fits",im2
   where "image1.fits" is a filename (can contain widl cards)
   arguments can mix strings (filenames, possibly with widlcards),
   and images or data cube.

   EXAMPLES:
   $ spydr --dpi 80 20070730_2*.fits
   $ spydr -c 20070730_2[2-3]?.fits 20070730_241.fits
   > spydr,"~/ascam/2007jun26/20070625T2000*.fits"
   > spydr,["20070730_1[1-3].fits","20070730_23.fits"]
   > spydr,"20070730_1[1-3].fits","20070730_23.fits"
   > spydr,image,append=1
   > spydr,im1,"cube45.fits"

   KEYWORDS:
   wavelength=: set wavelength for the image/cube arguments
   pixsize=: set pixel size (plate scale) for the image/cube arguments
   name=: set name 9for display) for the image/cube arguments
   append=append image/cube argument to existing image stack

   RESTRICTIONS:
   - only fits images handled to date
   - the ITT display is not very well handled
   
   USE:
   Once loaded, number of possibilities are offered by the GUI.
   There is a number of shortcuts. Type "?" or og to the help
   menu to list them all. Shortcuts are events are received only
   when the cursor is in the main graphic window.

   INSTALLATION:
   - Linux packages normally install an executable and man page. With other
     installers, or other OSes, you can define an alias or write a wrapper
     to conveniently call spydr from the command line without having to write
     the "yorick -i ..."
     Example of a spydr wrapper:
     #!/bin/sh
     rlwrap yorick -i spydr/spydr.i $* || yorick -i spydr/spydr.i $*

   SEE ALSO:
 */
{
  extern spydrs,imnum;
  extern spydr_im,cmin,cmax;
  extern spydr_fh, spydr_nim;
  extern xcut, ycut, imnamen;
  extern flushing;
  local  imname,im,nim,wavelength,pixsize,im;

  default_wavelength = (wavelength?wavelength:spydr_wavelength);
  default_pixsize = (pixsize?pixsize:spydr_pixsize);
  default_imname = (name?name:"image");

  if (spydr_append) {
    // ugly hack to circumvent funcdef inability to deal with keywords
    append=1;
    spydr_append=0;
  }
  
  if (_spydr_pyk_proc==[]) append=0; // does not make sense in that case
  
  if (!append) spydr_clean;
  else {
    orig_nim=spydr_nim;
    window,spydr_wins(1);
    unzoom;
  }
  
  // loop on # of arguments
  do {
    
    if (vimage==[]) break; // spydr called without argument.
    
    if (structof(vimage)==string) {  
      //===============================
      // Dealing with filename. read it
      //===============================
        
      // loop on number of elements in argument (if string vector)
      for (nn=1;nn<=numberof(vimage);nn++) {

        image = vimage(nn);
        // image is a single element, but may contain wildcards (if passed
        // from within yorik, otherwise, shell expands it.
      
        // expand image name in case of wild cards
        imname = findfiles(image);
        if (imname==[]) {
          spydr_pyk_error,swrite(format="Can not find %s\n",image);
          if (spydr_context=="called_from_shell") quit;
          error,swrite(format="Can not find %s\n",image);
        }
        
        // loop on elements
        for (mm=1;mm<=numberof(imname);mm++) {
          // read out image:
          im = spydr_fits_read(imname(mm),fh,hdu=(hdu?hdu:spydr_hdu));
          
          wavelength = figure_image_wavelength(fh);
          pixsize = figure_image_pixsize(fh);

          if (dimsof(im)(1)==2) { // single image
            nim = 1;
            grow,spydrs,spydr_struct();
            spydrs(0).pim = &im;
            spydrs(0).pixsize = spydrs(0).opixsize = pixsize;
            spydrs(0).wavelength = wavelength;
            spydrs(0).name = spydrs(0).saveasname = basename(imname(mm));
            spydrs(0).dims = dimsof(im);
          } else if (dimsof(im)(1)==3) { // data cube.
            nim = dimsof(im)(4);
            // let's splice the cube in single images for spydr_cube:
            for (i=1;i<=nim;i++) {
              grow,spydrs,spydr_struct();
              spydrs(0).pim = &(im(,,i));
              spydrs(0).pixsize = spydrs(0).opixsize = pixsize;
              spydrs(0).wavelength = wavelength;
              spydrs(0).name = basename(imname(mm));
              spydrs(0).name += swrite(format=" %d/%d",i,nim);
              spydrs(0).saveasname = spydrs(0).name;
              spydrs(0).dims = dimsof(im(,,i));
            }
          } else {
            info,image;
            spydr_pyk_error,"spydr only works on images and data cubes";
            if ((spydr_context=="called_from_shell")&&(spydr_nim==0)) quit;
            error,"spydr only works on images and data cubes";
          }
          spydr_nim += nim;
        }
      }
      
    } else { 
      //=========================================
      // image argument are images, not file name
      //=========================================
      
      image = vimage;
      if (dimsof(image)(1)==2) { // single image
        nim = 1;
        grow,spydrs,spydr_struct();
        spydrs(0).pim = &image;
        spydrs(0).pixsize = spydrs(0).opixsize = pixsize;
        spydrs(0).wavelength = wavelength;
        default_imname = (name?name:"image")+swrite(format="%d",++imnamen);
        spydrs(0).name = spydrs(0).saveasname = default_imname;
        spydrs(0).dims = dimsof(image);
      } else if (dimsof(image)(1)==3) { // data cube
        nim = dimsof(image)(4);
        // let's splice the cube in single images for spydr_cube:
        default_imname = (name?name:"cube")+swrite(format="%d",++imnamen);
        for (i=1;i<=nim;i++) {
          grow,spydrs,spydr_struct();
          spydrs(0).pim = &(image(,,i));
          spydrs(0).pixsize = spydrs(0).opixsize = default_pixsize;
          spydrs(0).wavelength = default_wavelength;
          spydrs(0).name = default_imname;
          spydrs(0).name += swrite(format=" %d/%d",i,nim);
          spydrs(0).saveasname = spydrs(0).name;
          spydrs(0).dims = dimsof(image(,,i));
        }
      } else {
        info,image;
        spydr_pyk_error,"spydr only works on images and data cubes";
        if ((spydr_context=="called_from_shell")&&(spydr_nim==0)) quit;
        error,"spydr only works on images and data cubes";
      }
      spydr_nim += nim;
      
    }
  } while ((vimage=next_arg())!=[]);

  // binsize=1 if image=integers, 0 else.
  // if 0, use nbin in hist calculation
  //if (!spydr_histbinsize) spydr_histbinsize = (max(abs(*(spydrs(1).pim))%1)==0?1:0);
  
  // span the python process, and hook to existing _spydr_pyk_proc (see spydr_pyk.i)
  if (!_spydr_pyk_proc) {
    _spydr_pyk_proc = spawn(pyk_cmd, _spydr_pyk_callback);
    write,"\r SPYDR v"+spydr_version+" ready                                                         ";
  } else {
    // there's already a GUI around. hence we're not going to receive
    // a signal from python to bring up windows and display. we have
    // to init the display here:
    if (append) set_imnum,orig_nim+1; else set_imnum,1;
    gui_update;
    disp_cpc;
    spydr_disp;
    if (spydr_showlower) plot_histo;
    write,"\r                                                                     ";
  }
  if (flushing==0) spydr_pyk_flush;
}


// ======================================
// Processing of command line arguments
// setting default, reading out conf file
// spawning python process.
//=======================================

// when called from the command line:
arg     = get_argv();

// were we invoqued from shell or from the yorick prompt?
spydr_context = "called_from_session";
if (anyof(arg=="spydr.i")) spydr_context="called_from_shell";

//--------------------------------
// check that yorick version >= 2.1.05

yv1=yv2=yv3=0;
sread,Y_VERSION,format="%d.%d.%d",yv1,yv2,yv3;

vok=( (yv1>2) | ( (yv1==2)&(yv2>1) ) | ( (yv1==2)&(yv2==1)&(yv3>=5) ));

if (!vok) {
  spydr_pyk_error,"spydr requires yorick version 2.1.05 or greater";
  if (spydr_context=="called_from_shell") quit;
  error,"spydr requires yorick version 2.1.05 or greater";
 }

//--------------------------------
// look for python and glade files
Y_PYTHON = get_env("Y_PYTHON");
Y_GLADE  = get_env("Y_GLADE");
Y_CONF   = get_env("Y_CONF");

y_user = streplace(Y_USER,strfind("~",Y_USER),get_env("HOME"))

if (noneof(Y_PYTHON)) \
  Y_PYTHON="./:"+y_user+":"+pathform(_(y_user,Y_SITES,Y_SITE)+"python/");
if (noneof(Y_GLADE)) \
  Y_GLADE="./:"+y_user+":"+pathform(_(y_user,Y_SITES,Y_SITE)+"glade/");

// try to find spydr.py
path2py = find_in_path("spydr.py",takefirst=1,path=Y_PYTHON);
if (is_void(path2py)) {
  // not found. bust out
  spydr_pyk_error,swrite(format="Can't find spydr.py in %s.\n",Y_PYTHON);
  if (spydr_context=="called_from_shell") quit;
  error,swrite(format="Can't find spydr.py in %s.\n",Y_PYTHON);
 }
path2py = dirname(path2py);
write,format=" Found spydr.py in %s\n",path2py;

// try to find spydr.glade
path2glade = find_in_path("spydr.glade",takefirst=1,path=Y_GLADE);
if (is_void(path2glade)) {
  // not found. bust out
  spydr_pyk_error,swrite(format="Can't find spydr.glade in %s\n",Y_GLADE);
  if (spydr_context=="called_from_shell") quit;
  error,swrite(format="Can't find spydr.glade in %s\n",Y_GLADE);
 }
path2glade = dirname(path2glade);
write,format=" Found spydr.glade in %s\n",path2glade;


//---------------------------------------------------------
// parse arguments a first time for possible spydr_conffile
parse_flags,arg;

// include configuration file
if (spydr_conffile==[]) spydr_conffile = which_spydrconf();
write,format=" Using %s\n",spydr_conffile;
if (findfiles(spydr_conffile)==[]) {
  spydr_pyk_error,swrite(format="Can not find configuration file %s",spydr_conffile);
  if (spydr_context=="called_from_shell") quit;
  error,swrite(format="Can not find configuration file %s",spydr_conffile);
 }
require,spydr_conffile;

// set other defaults
spydr_ncolors=240;
from_disp = 1;
spydr_dpi = spydr_defaultdpi;
if (spydr_histbinsize==[]) spydr_histbinsize=0;
if (spydr_wins==[]) spydr_wins = [0,0,0];
pldefault,maxcolors=spydr_ncolors;

// parse arguments a second time (to override conffile defaults)
targets = parse_flags(arg);

// spawned gtk interface
python_exec = path2py+"/spydr.py";
pyk_cmd=[python_exec,path2glade,swrite(format="%d",spydr_showlower),swrite(format="%d",spydr_dpi), \
         swrite(format="%d",spydr_showplugins)];



if (spydr_context=="called_from_shell") spydr,targets;
