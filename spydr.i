/* spydr.i
 * main function to call the pygtk GUI to spydr.
 * syntax: yorick -i spydr.i imname ... (see README)
 *
 * This file is part of spydr, an image viewer/data analysis tool
 *
 * $Id: spydr.i,v 1.14 2008-01-24 15:05:17 frigaut Exp $
 *
 * Copyright (c) 2007, Francois Rigaut
 * 
 * This program is free software; you can redistribute it and/or  modify it
 * under the terms of the GNU General Public License  as  published  by the
 * Free Software Foundation; either version 2 of the License,  or  (at your
 * option) any later version.
 *
 * This program is distributed in the hope  that  it  will  be  useful, but
 * WITHOUT  ANY   WARRANTY;   without   even   the   implied   warranty  of
 * MERCHANTABILITY or  FITNESS  FOR  A  PARTICULAR  PURPOSE.   See  the GNU
 * General Public License for more details (to receive a  copy  of  the GNU
 * General Public License, write to the Free Software Foundation, Inc., 675
 * Mass Ave, Cambridge, MA 02139, USA).
 *
 * $Log: spydr.i,v $
 * Revision 1.14  2008-01-24 15:05:17  frigaut
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
 * - fixed problem with (pyk) I/O interupt, which was due to calling pyk_flush
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

spydr_version = "0.7.0";

require,"pyk.i";
require,"astro_util1.i";
require,"spydr_psffit.i";
require,"util_fr.i";
require,"histo.i";
require,"plot.i";
require,"spydr_plugins.i";
require,"pathfun.i";

struct spydr_struct{
  pointer pim;
  long    nim;
  long    dims(3);
  double  pixsize;
  double  wavelength;
  string  name;
  float   cmin;
  float   cmax;
  string  space;
};

flushing_interval=0.25;
//=============================
//  PYK wrapping functions
//=============================


func pyk_status_push(msg,id=)
{
  if (id==[]) id=1;
  pyk,swrite(format="pyk_status_push(%d,'%s')",id,msg);
}


func pyk_status_pop(id=)
{
  if (id==[]) id=1;
  pyk,swrite(format="pyk_status_pop(%d)",id);
}


func pyk_info(msg)
{
  if (numberof(msg)>1) msg=sum(msg+"\\n");
  // or streplace(msg,strfind("\n",msg),"\\n")
  pyk,swrite(format="pyk_info('%s')",msg);
}


func pyk_info_w_markup(msg)
{
  if (numberof(msg)>1) msg=sum(msg+"\\n");
  // or streplace(msg,strfind("\n",msg),"\\n")
  pyk,swrite(format="pyk_info_w_markup('%s')",msg);
}


func pyk_error(msg)
{
  if (numberof(msg)>1) msg=sum(msg+"\\n");
  // ok, here the problem is that "fatal errors", when called from shell,
  // should bail you out (quit yorick). But if they do, then the python
  // process is also killed and then the error message never appears on screen.
  // thus the use of zenity in *all* cases.
  //  if (_pyk_proc) {
  //    pyk,swrite(format="pyk_error('%s')",msg);
  //  } else { // python not started yet, use zenity
    system,swrite(format="zenity --error --text=\"%s\"",msg);
    //  }
}


func pyk_warning(msg)
{
  if (numberof(msg)>1) msg=sum(msg+"\\n");
  pyk,swrite(format="pyk_warning('%s')",msg);
}


func gui_progressbar_frac(frac) {
  pyk,swrite(format="progressbar.set_fraction(%f)",float(frac));
}


func gui_progressbar_text(text) {
  pyk,swrite(format="progressbar.set_text('%s')",text);
}


func gui_message(msg) {
  pyk,swrite(format="statusbar.push(1,'%s')",msg);
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
  window,spydr_wins(2),dpi=30,wait=1,style="nobox.gs",parent=pid2,\
    ypos=-27,xpos=-3;
  limits,square=1;
  window,spydr_wins(3),dpi=spydr_dpi,wait=spydr_showlower,style="spydr2.gs",\
    xpos=-2,ypos=-2,parent=pid3;
  window,spydr_wins(1);
  pyk,"done_init = 1";
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
    if (from_disp==3) explimits,old_limits;
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
}

func explimits(lim)
{
  limits,lim(1),lim(2),lim(3),lim(4);
}

func disp_tv(void)
// pli display, main window
{
  extern imnum;

  if (imnum==[]) return;
  //  write,format="%s ","*";
  window,spydr_wins(1);
  fma;
  pli,bytscl(spydr_im,cmin=cmin,cmax=cmax);
  spydr_pltitle,spydrs(imnum).name+swrite(format=" %dx%d",spydrs(imnum).dims(2),spydrs(imnum).dims(3));
  spydr_xytitles,"pixels","pixels";
  colorbar,adjust=-0.024,levs=10;
  // refresh zoom now
  disp_zoom,once=1;
}
spydr_disp = disp_tv;
  


func disp_contours(void,nofma=)
// contour display, main window
{
  window,spydr_wins(1);
  if (nofma!=1) fma;
  xy = indices(spydrs(imnum).dims)-0.5;
  levs = span(cmin,cmax,spydr_nlevs)(2:-1);
  if (spydr_filled) {
    plfc,spydr_im,xy(,,2),xy(,,1),levs=levs;
    colorbar,adjust=-0.024,levs=10;
  }
  plc,spydr_im,xy(,,2),xy(,,1),levs=levs,smooth=spydr_smooth,marks=1,marker='A',msize=1.2,mspace=0.2;
  spydr_pltitle,spydrs(imnum).name+swrite(format=" %dx%d",spydrs(imnum).dims(2),spydrs(imnum).dims(3));
  spydr_xytitles,"pixels","pixels";
  levstr = sum(swrite(format="%.1f",levs)+", ");
  levstr = "["+strpart(levstr,:-2)+"]";
  pyk_status_push,"levels="+levstr;
  limits,old_limits;
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
  } else if (spydr_itt>=4) { // log
    ind = log10(span(10.^(-spydr_log_itt_dex),1.,spydr_ncolors)); // 8 dex
    ind -= min(ind);
    ind /= max(ind);
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
    pyk,swrite(format="y_set_cmincmax(%f,%f,%f,1)",float(cmin),float(cmax),float(cmax-cmin)/100.);  
}


func rad4zoom_incr(void) { rad4zoom=min(rad4zoom+1,spydrs(imnum).dims(2)/2); }
func rad4zoom_decr(void) { rad4zoom=max(rad4zoom-1,0); }


//=================================
// PLOT functions
//=================================

func show_lower_gui(visibility)
{
  pyk,swrite(format="glade.get_widget('togglelower').set_active(%d)",visibility(1));
}

func plot_cut(void)
{
  extern onedx,onedy;
  
  curw = current_window();
  window,spydr_wins(1);
  m=mouse(1,2,"Click and drag over desired cut");
  x1=m(1); y1=m(2);
  x2=m(3); y2=m(4);
  d = abs(x2-x1,y2-y1);
  x = span(x1,x2,long(ceil(d)));
  y = span(y1,y2,long(ceil(d)));
  cut_y = spline2(spydr_im,x,y);
  cut_x = sqrt( (x-x1)^2. + (y-y1)^2.);
  
  show_lower_gui,1;
  
  window,spydr_wins(3);
  fma;
  plh,cut_y,cut_x;
  limits,square=0; limits;
  spydr_xytitles,"pixels","value";
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
  cut_x=indgen(spydrs(imnum).dims(2));
  plh,cut_y,cut_x;
  spydr_xytitles,"pixels","value";
  spydr_pltitle,swrite(format="line# %d",j);
  limits,i1,i2;
  window,curw;
  onedx=cut_x;
  onedy=cut_y;
}


func plot_ycut(i)
{
  extern onedx,onedy;
  
  if (spydr_nim<1) return;

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
  cut_x=indgen(spydrs(imnum).dims(3));
  plh,cut_y,cut_x;
  spydr_xytitles,"pixels","value";
  spydr_pltitle,swrite(format="column# %d",i);
  limits,j1,j2;
  window,curw;
  onedx=cut_x;
  onedy=cut_y;
}


func fit_gaussian_1d(void)
{
  extern onedx,onedy;

  if (noneof(onedy)) pyk_status_push,"Nothing to fit";
  if (numberof(onedy)!=numberof(onedx)) \
    pyk_status_push,"onedy and onedx do not have the same dimensions!";
  
  a = [0.,max(onedy),onedx(wheremax(onedy)),3.];
  clmfit,onedy,onedx,a,"a(1)+a(2)*exp(-0.5*((x-a(3))/a(4))^2.)",yfit;
  curw = current_window();
  window,spydr_wins(3);
  plh,yfit,onedx,color="red";
  window,curw;
  pyk_status_push,swrite(format="gaussian, max=%f @ x=%.3f, sig=%.3fpix (fwhm=%.3f), background=%f",\
                         a(2),a(3),a(4),a(4)*2.355,a(1));
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
  plp,subim,d,symbol=default_symbol,size=0.3;
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
  pyk_status_push,swrite(format=" %s: avg=%4.7g | med=%4.7g | rms=%4.7g",
                         spydrs(imnum).name,avg(subim),sedgemedian(subim(*)),subim(*)(rms));
  spydr_xytitles,"value","number in bin";
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

func spydr_cubeops(opn)
{
  local cube;
  if (spydr_nim<1) return;
  
  if (nallof(spydrs.dims==spydrs(1).dims)) {
    pyk_error,"cubeops: all images must have the same size";
    return;
  }
  pyk,"set_cursor_busy(1)";
  pyk_status_push,"Processing cube operation, please wait...";
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
  pyk,"set_cursor_busy(0)";
  pyk_status_push,"Processing cube operation: Done.";
}


func spydr_rebin(fact)
// rebin the image by 2,3,4
{
  extern spydr_im_orig,spydr_im,cur_limits,rebin_init,old_fact;

  window,spydr_wins(1);

  if (rebin_init==[]) {
    spydr_im_orig=spydr_im;
    old_fact=1;
    rebin_init=1;
  }
  these_limits = limits();
  these_limits(1:4) /= old_fact; // what were the real limits with previous fact
  spydr_im = spline2(spydr_im_orig,fact); // interpolate
  spydrs(imnum).dims = dimsof(spydr_im); // update dims
  //  spydr_disp; // display
  // set news limits so that area displayed is unchanged:
  limits,_(these_limits(1:4)*fact,these_limits(5)); 
  old_fact = fact; // keep for next rebin
}


func get_subim(&x1,&x2,&y1,&y2)
{
  if (spydr_nim<1) return;
  curw = current_window();
  window,spydr_wins(1);
  lim=limits();
  x1=round(clip(lim(1),1,spydrs(imnum).dims(2)));
  x2=round(clip(lim(2),1,spydrs(imnum).dims(2)));
  y1=round(clip(lim(3),1,spydrs(imnum).dims(3)));
  y2=round(clip(lim(4),1,spydrs(imnum).dims(3)));
  if ( (x1==x2) || (y1==y2) ) {
    pyk_error,"Nothing to show";
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
  pyk_status_push,"\"X\" again to stop continuous X cuts";
}


func toggle_ycut(void) {
  extern xcut, ycut;
  xcut=0;
  ycut = 1-ycut;
  if (ycut) plot_ycut;
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

  if (imnum==[]) return; // GUI open but no image
  
  pyk,swrite(format="window.set_title('spydr - %s')",spydrs(imnum).name); 
  pyk,swrite(format="y_parm_update('binsize',%f)",float(spydr_histbinsize));
  pyk,swrite(format="y_parm_update('nlevs',%d)",long(spydr_nlevs));
  pyk,swrite(format="y_parm_update('pixsize',%f)",float(spydrs(imnum).pixsize));
  pyk,swrite(format="y_parm_update('boxsize',%d)",long(spydr_boxsize));
  pyk,swrite(format="y_parm_update('saturation',%f)",float(spydr_saturation));
  pyk,swrite(format="y_parm_update('airmass',%f)",float(spydr_airmass));
  pyk,swrite(format="y_parm_update('wavelength',%f)",float(spydrs(imnum).wavelength));
  pyk,swrite(format="y_parm_update('teldiam',%f)",float(spydr_teldiam));
  pyk,swrite(format="y_parm_update('zero_point',%f)",float(spydr_zero_point));
  pyk,swrite(format="y_parm_update('cobs',%f)",float(spydr_cobs));
  pyk,swrite(format="y_parm_update('strehl_aper_radius',%f)",float(spydr_strehlmask));
  pyk,swrite(format="y_set_checkbutton('compute_strehl',%d)",long(compute_strehl));
  pyk,swrite(format="glade.get_widget('plugins').set_active(%d)",spydr_showplugins);
  pyk,swrite(format="y_set_checkbutton('output_magnitudes',%d)",long(output_magnitudes));
  pyk,swrite(format="y_set_cmincmax(%f,%f,%f,0)",float(cmin),float(cmax),float(cmax-cmin)/100.);
  pyk,swrite(format="y_set_lut(%d)",spydr_lut);
  pyk,swrite(format="y_set_invertlut(%d)",spydr_invertlut);
  pyk,swrite(format="y_set_itt(%d)",clip(long(spydr_itt-1),0,3));  
  pyk,"glade.get_widget('menubar_images').set_sensitive(1)";
  pyk,"glade.get_widget('menubar_ops').set_sensitive(1)";
  sync_view_menu;
}


func imchange_update(void)
{
  extern imnum,cmin,cmax;
  
  pyk,swrite(format="y_parm_update('pixsize',%f)",float(spydrs(imnum).pixsize));
  pyk,swrite(format="y_parm_update('wavelength',%f)",float(spydrs(imnum).wavelength));
  pyk,swrite(format="y_parm_update('zero_point',%f)",float(spydr_zero_point));
  pyk,swrite(format="y_set_cmincmax(%f,%f,%f,0)",float(cmin),float(cmax),float(cmax-cmin)/100.);
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
  cur = long(cur);
  cur(1:2) = cur(1:2)+1; //ceil
  return cur;
}
  

stop_zoom=0;
func spydr_clean(void)
{
  extern spydrs,imnum;
  extern spydr_im,cmin,cmax;
  extern spydr_fh,x1,x2,y1,y2;
  extern imnamen,spydr_nim,xcut,ycut;
  
  /*
    winkill,spydr_wins(1);
    winkill,spydr_wins(2);
    winkill,spydr_wins(3);
  */
  
  spydr_get_available_windows;
  imnamen=spydr_nim=xcut=ycut=0;
  stop_zoom=1;
  spydrs=spydr_im=imnum=spydr_fh=x1=x2=y1=y2=[];
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
    pyk,swrite(format="y_set_xyz('%d','%d','%4.7g')",\
               i,j,float(spydr_im(i,j)));

    local_rad=5;
    x1 = clip(i-local_rad,1,spydrs(imnum).dims(2));
    x2 = clip(i+local_rad,1,spydrs(imnum).dims(2));
    y1 = clip(j-local_rad,1,spydrs(imnum).dims(3));
    y2 = clip(j+local_rad,1,spydrs(imnum).dims(3));
    pyk,swrite(format="y_text_parm_update('localmax','%4.7g')",\
               float(max(spydr_im(x1:x2,y1:y2))));
    sim=spydr_im(x1:x2,y1:y2);
    wm = where2(sim==max(sim))(,1)-local_rad-1;

    // FIXME: blue cursor is not at correct position when pointing lower than smaller indice

    x1 = i-rad4zoom;
    x2 = i+rad4zoom;
    y1 = j-rad4zoom;
    y2 = j+rad4zoom;
    
    if (x1<1) { x1=1; x2=x1+(2*rad4zoom+1); }
    else if (x2>spydrs(imnum).dims(2)) { x2=spydrs(imnum).dims(2); x1=x2-(2*rad4zoom+1); }      

    if (y1<1) { y1=1; y2=y1+(2*rad4zoom+1); }
    else if (y2>spydrs(imnum).dims(3)) { y2=spydrs(imnum).dims(3); y1=y2-(2*rad4zoom+1); }      

    window,spydr_wins(2);
    fma;
    if (zoom_cmincmax) pli,bytscl(spydr_im(x1:x2,y1:y2),cmin=cmin,cmax=cmax);
    else pli,spydr_im(x1:x2,y1:y2);
    limits,1,2*rad4zoom,1,2*rad4zoom;
    // plot local maxima location
    plp,j-y1+wm(2)+0.5,i-x1+wm(1)+0.5,symbol=2,color="blue",width=3;
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
               " -/+: Decrease/Increase zoom factor in zoom window",
               " u:   Unzoom",
               " ?:   This help","</span>"];
  write,format="%s\n",help_text(2:-1);
  pyk_info_w_markup,help_text;
}


func strehl_convert(sfrom,wfrom,wto)
{
  return exp(wfrom^2.*log(sfrom)/wto^2.)
}


func set_imnum(nn,from_python,force=)
{
  extern spydrs,imnum;
  extern spydr_im,cmin,cmax;
  extern gui_realized;

  //write,format="YORICK: Request for set_imnum %d\n",nn;
  
  if ((nn==imnum)&&(!force)) return;
  if (nn>spydr_nim) return;
  
  imnum = nn;
  spydr_im = *(spydrs(imnum).pim);
  spydrs(imnum).dims = dimsof(spydr_im);

  if ((spydrs(imnum).cmin==0)&(spydrs(imnum).cmax==0)) disp_cpc,1;
  else {
    cmin = spydrs(imnum).cmin;
    cmax = spydrs(imnum).cmax;
  }
  if ((from_python==[])&&(gui_realized)) {
    pyk,swrite(format="set_imnum(%d,%d,%d)",nn,spydr_nim,(spydr_nim>1));
  }
  if (gui_realized) \
    pyk,swrite(format="window.set_title('spydr - %s')",spydrs(nn).name); 
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
  if ((abs(pycmin-cmin)/(cmax-cmin))<1e-3) return;
  cmin = spydrs(imnum).cmin = pycmin;
  spydr_disp;
}

func set_cmax(pycmax)
{
  extern spydrs,cmax,imnum;
  //  write,format="pycmax=%f, cmax=%f\n",pycmax,cmax;
  // because the precision was cut by the yorick -> python -> yoric
  // transfer, we have to allow for some slack
  if ((abs(pycmax-cmax)/(cmax-cmin))<1e-3) return;
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

func spydr_fits_read(imname,&fh)
{
  extern warning_done;  

  write,format="\r Reading %s",imname;
  
  im = fits_read(imname,fh);
  if (numberof(im)==0) {
    // try next hdu (e.g. niri)
    im = fits_read(imname,fh,hdu=2);
  }
  if (numberof(im)==0) {
    pyk_error,imname+"found, but no data";
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

func pyk_flush(void)
{
  extern flushing;
  if (_pyk_proc==[]) {
    flushing=0;
    return;
  }
  flushing=1;
  pyk,"yo2py_flush";
  after,flushing_interval,pyk_flush;
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
  write,format="%s\n","       --pixsize|platescale value --boxsize value --saturation value ";
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
    pyk_error,swrite(format="Can't find spydr.conf in %s:%s:%s\n",path1,path2,path3);
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
  pyk,swrite(format="add_to_image_menu('%s',%d)",item,ind);
}

func sync_view_menu(void)
{
  pyk,"reset_image_menu()";
  for (i=1;i<=numberof(spydrs);i++) {
    pyk,swrite(format="add_to_image_menu('%s',%d)",spydrs(i).name,i);
  }
}


//=======================
// MAIN ROUTINE
//=======================
func spydr(vimage,..,wavelength=,pixsize=,name=,append=)
/* DOCUMENT spydr,image
   Software Package in Yorick for Data Reduction
   
   From the command line:
   $ yorick -i path_to_spydr/spydr.i image1 image2 ...
   where image can contain wild cards

   or, within yorick:
   spydr,"image1",...
   where image1 is a filename (can contain widl cards)
   or
   spydr,images
   where images can be a single image or a datacube.

   EXAMPLES:
   $ spydr 20070730_2*.fits
   $ spydr 20070730_2[2-3]?.fits 20070730_241.fits
   > spydr,"~/ascam/2007jun26/20070625T2000*.fits"
   > spydr,["20070730_1[1-3].fits","20070730_23.fits"]
   > spydr,image
   > spydr,[im1,im2]

   RESTRICTIONS:
   - all images have to be of the same size
   - only fits images handled to date
   - the ITT display is not very well handled
   
   USE:
   Once loaded, number of possibilities are offered by the GUI.
   There is a number of shortcuts. Type "?" or og to the help
   menu to list them all. Shortcuts are events are received only
   when the cursor is in the main graphic window.

   INSTALLATION:
   - You can define an alias or write a wrapper to conveniently
     call spydr from the command line without having to write the
     yorick -i ...
     Example of a spydr wrapper:
     #!/bin/sh
     yorick -i spydr/spydr.i $*

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
  
  if (_pyk_proc==[]) append=0; // does not make sense in that case
  
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
          pyk_error,swrite(format="Can not find %s\n",image);
          if (spydr_context=="called_from_shell") quit;
          error,swrite(format="Can not find %s\n",image);
        }
        
        // loop on elements
        for (mm=1;mm<=numberof(imname);mm++) {
          // read out image:
          im = spydr_fits_read(imname(mm),fh);
        
          wavelength = figure_image_wavelength(fh);
          pixsize = figure_image_pixsize(fh);

          if (dimsof(im)(1)==2) { // single image
            nim = 1;
            grow,spydrs,spydr_struct();
            spydrs(0).pim = &im;
            spydrs(0).pixsize = pixsize;
            spydrs(0).wavelength = wavelength;
            spydrs(0).name = basename(imname(mm));
            spydrs(0).dims = dimsof(im);
          } else if (dimsof(im)(1)==3) { // data cube.
            nim = dimsof(im)(4);
            // let's splice the cube in single images for spydr_cube:
            for (i=1;i<=nim;i++) {
              grow,spydrs,spydr_struct();
              spydrs(0).pim = &(im(,,i));
              spydrs(0).pixsize = pixsize;
              spydrs(0).wavelength = wavelength;
              spydrs(0).name = basename(imname(mm));
              spydrs(0).name += swrite(format=" %d/%d",i,nim);
              spydrs(0).dims = dimsof(im(,,i));
            }
          } else {
            info,image;
            pyk_error,"spydr only works on images and data cubes";
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
        default_imname = (name?name:"image")+swrite(format="%d",++imnamen);
        spydrs(0).name = default_imname;
        spydrs(0).dims = dimsof(image);
      } else if (dimsof(image)(1)==3) { // data cube
        nim = dimsof(image)(4);
        // let's splice the cube in single images for spydr_cube:
        default_imname = (name?name:"cube")+swrite(format="%d",++imnamen);
        for (i=1;i<=nim;i++) {
          grow,spydrs,spydr_struct();
          spydrs(0).pim = &(image(,,i));
          spydrs(0).pixsize = default_pixsize;
          spydrs(0).wavelength = default_wavelength;
          spydrs(0).name = default_imname;
          spydrs(0).name += swrite(format=" %d/%d",i,nim);
          spydrs(0).dims = dimsof(image(,,i));
        }
      } else {
        info,image;
        pyk_error,"spydr only works on images and data cubes";
        if ((spydr_context=="called_from_shell")&&(spydr_nim==0)) quit;
        error,"spydr only works on images and data cubes";
      }
      spydr_nim += nim;
      
    }
  } while ((vimage=next_arg())!=[]);

  // binsize=1 if image=integers, 0 else.
  // if 0, use nbin in hist calculation
  //if (!spydr_histbinsize) spydr_histbinsize = (max(abs(*(spydrs(1).pim))%1)==0?1:0);
  
  // span the python process, and hook to existing _pyk_proc (see pyk.i)
  if (!_pyk_proc) {
    _pyk_proc = spawn(pyk_cmd, _pyk_callback);
    write,"\r SPYDR ready                                                         ";
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
  if (flushing==0) pyk_flush;
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
  pyk_error,swrite(format="Can't find spydr.py in %s.\n",Y_PYTHON);
  if (spydr_context=="called_from_shell") quit;
  error,swrite(format="Can't find spydr.py in %s.\n",Y_PYTHON);
 }
path2py = dirname(path2py);
write,format=" Found spydr.py in %s\n",path2py;

// try to find spydr.glade
path2glade = find_in_path("spydr.glade",takefirst=1,path=Y_GLADE);
if (is_void(path2glade)) {
  // not found. bust out
  pyk_error,swrite(format="Can't find spydr.glade in %s\n",Y_GLADE);
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
  pyk_error,swrite(format="Can not find configuration file %s",spydr_conffile);
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
/*  if (numberof(targets)>=1) spydr,targets;
  else {
    // called without argument. Start nevertheles (user may open
    // files with the "open" menu)
    if (!_pyk_proc) {
      _pyk_proc = spawn(pyk_cmd, _pyk_callback);
      write,"\r SPYDR ready";
    }
  }
 }
*/
