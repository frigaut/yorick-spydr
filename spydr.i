/* spydr.i
 * main function to call the pygtk GUI to spydr.
 * syntax: yorick -i spydr.i imname ... (see README)
 *
 * This file is part of spydr, an image viewer/data analysis tool
 *
 * $Id: spydr.i,v 1.6 2007-12-26 17:41:47 frigaut Exp $
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
 * Revision 1.6  2007-12-26 17:41:47  frigaut
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

spydr_version = "0.5.3";

require,"pyk.i";
require,"mouse_nowait.i";
require,"astro_util1.i";
require,"spydr_psffit.i";
//require,"usleep.i";
require,"util_fr.i";
require,"histo.i";
require,"plot.i";
require,"spydr_plugins.i";
require,"pathfun.i";

func which_spydrconf(void) {
  // look for a possible user's spydr.conf:
  require,"pathfun.i";
  local file,path;
  path1 = pathform(_("/etc/",Y_SITE,Y_USER));
  file = find_in_path("spydr.conf",takefirst=1,path=path1);
  if (file==[]) {
    path2 = pathform(_(Y_SITE,Y_USER)+"share/");
    file = find_in_path("spydr.conf",takefirst=1,path=path2);
  }
  if (file==[]) {
    path3 = pathform(_(Y_SITE,Y_USER)+"share/spydr/");
    file = find_in_path("spydr.conf",takefirst=1,path=path3);
  }
  if (file==[]) \
    error,swrite(format="Can't find spydr.conf in %s:%s:%s\n",path1,path2,path3);
  
  return file;
}

require,which_spydrconf();

spydr_ncolors=240;
from_disp = 1;

if (spydr_histbinsize==[]) spydr_histbinsize=0;
if (spydr_wins==[]) spydr_wins = [0,0,0];

pldefault,maxcolors=spydr_ncolors;


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
  pyk,swrite(format="pyk_info('%s')",msg)
}


func pyk_info_w_markup(msg)
{
  if (numberof(msg)>1) msg=sum(msg+"\\n");
  // or streplace(msg,strfind("\n",msg),"\\n")
  pyk,swrite(format="pyk_info_w_markup('%s')",msg)
}


func pyk_error(msg)
{
  if (numberof(msg)>1) msg=sum(msg+"\\n");
  pyk,swrite(format="pyk_error('%s')",msg)
}


func pyk_warning(msg)
{
  if (numberof(msg)>1) msg=sum(msg+"\\n");
  pyk,swrite(format="pyk_warning('%s')",msg)
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
  window,spydr_wins(1),dpi=spydr_defaultdpi,wait=1,\
    style="spydr.gs",parent=pid1;
  disp_cpc;
  disp_tv;
  limits,square=1;
  window,spydr_wins(2),dpi=30,wait=1,style="nobox.gs",parent=pid2,ypos=-25;
  limits,square=1;
  window,spydr_wins(3),dpi=spydr_defaultdpi,wait=1,style="spydr2.gs",\
    parent=pid3,ypos=0;
  window,spydr_wins(3);
  plot_histo;
  window,spydr_wins(1);
  //  usleep,100;
  pyk,"done_init = 1";
  spydr_lut,0;
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

  window,spydr_wins(1);
  fma;
  pli,bytscl(spydr_im,cmin=cmin,cmax=cmax);
  spydr_pltitle,spydr_imname4title(imnum)+swrite(format=" %dx%d",spydr_dims(2),spydr_dims(3));
  spydr_xytitles,"pixels","pixels";
  colorbar,adjust=-0.024,levs=10
}
spydr_disp = disp_tv;
  


func disp_contours(void,nofma=)
// contour display, main window
{
  window,spydr_wins(1);
  if (nofma!=1) fma;
  xy = indices(spydr_dims)-0.5;
  levs = span(cmin,cmax,spydr_nlevs)(2:-1);
  if (spydr_filled) {
    plfc,spydr_im,xy(,,2),xy(,,1),levs=levs;
    colorbar,adjust=-0.024,levs=10;
  }
  plc,spydr_im,xy(,,2),xy(,,1),levs=levs,smooth=spydr_smooth,marks=1,marker='A',msize=1.2,mspace=0.2;
  spydr_pltitle,spydr_imname4title(imnum)+swrite(format=" %dx%d",spydr_dims(2),spydr_dims(3));
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
  plt, title, port(zcen:1:2)(1), port(4)+0.005,
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
  xytitles,xtitle,ytitle,adjust;

  pltitle_height = plth_save;
}


func spydr_lut(lut)
// change the LookUp Table and Intensity Transfer Table
{
  require,"idl-colors.i";
  extern rlut,glut,blut;
  local r,g,b;

  window,spydr_wins(1);
  
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
  if (spydr_itt==1) { // linear
    ind = span(0.,1.,spydr_ncolors);
  } else if (spydr_itt==2) { // sqrt
    ind = sqrt(span(0.,1.,spydr_ncolors));
  } else if (spydr_itt==3) { // square
    ind = (span(0.,1.,spydr_ncolors))^2.;
  } else if (spydr_itt==4) { // log
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
  extern cmin,cmax;
  
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
  pyk,swrite(format="y_set_cmincmax(%f,%f,%f,1)",float(cmin),float(cmax),float(cmax-cmin)/100.);  
}


func rad4zoom_incr(void) { rad4zoom=min(rad4zoom+1,spydr_dims(2)/2); }
func rad4zoom_decr(void) { rad4zoom=max(rad4zoom-1,0); }


//=================================
// PLOT functions
//=================================


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
  
  if (j==[]) j=get_cursor()(2);
  get_subim,i1,i2,j1,j2;
  curw = current_window();
  window,spydr_wins(3);
  fma;
  cut_y=spydr_im(,j);
  cut_x=indgen(spydr_dims(2));
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
  
  if (i==[]) i=get_cursor()(1);
  get_subim,i1,i2,j1,j2;
  curw = current_window();
  window,spydr_wins(3);
  fma;
  cut_y=spydr_im(i,);
  cut_x=indgen(spydr_dims(3));
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
  cur=get_cursor();
  subim=get_subim(i1,i2,j1,j2);
  curw = current_window();
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
  
  subim=get_subim(x1,x2,y1,y2);  //must be in window,1 when doing that.
  
  if (!spydr_histnbins) spydr_histnbins=100;
  if (spydr_histbinsize==0) binsize=(cmax-cmin)/spydr_histnbins;
  else binsize = spydr_histbinsize;
  
  hy = histo2(subim(*),hx,binsize=binsize,binmin=cmin,binmax=cmax);
  curw = current_window();
  window,spydr_wins(3);
  fma;
  plh,hy,hx;
  //  plmargin,0.02;
  spydr_pltitle,swrite(format="histogram of region [%d:%d,%d:%d]",x1,x2,y1,y2);
  pyk_status_push,swrite(format="  avg=%4.7g | med=%4.7g | rms=%4.7g",
                         avg(subim),sedgemedian(subim(*)),subim(*)(rms));
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


func spydr_rebin(fact)
// rebin the image by 2,3,4
{
  extern spydr_im_orig,cur_limits,rebin_init,old_fact;
  extern spydr_im,spydr_im,spydr_dims;

  window,spydr_wins(1);

  if (rebin_init==[]) {
    spydr_im_orig=spydr_im;
    old_fact=1;
    rebin_init=1;
  }
  these_limits = limits();
  these_limits(1:4) /= old_fact; // what were the real limits with previous fact
  spydr_im = spline2(spydr_im_orig,fact); // interpolate
  spydr_dims = dimsof(spydr_im); // update dims
  //  spydr_disp; // display
  limits,_(these_limits(1:4)*fact,these_limits(5)); // set news limits so that area displayed is unchanged.
  old_fact = fact; // keep for next rebin
  set_itt;
}


func get_subim(&x1,&x2,&y1,&y2)
{
  curw = current_window();
  window,spydr_wins(1);
  lim=limits();
  x1=round(clip(lim(1),1,spydr_dims(2)));
  x2=round(clip(lim(2),1,spydr_dims(2)));
  y1=round(clip(lim(3),1,spydr_dims(3)));
  y2=round(clip(lim(4),1,spydr_dims(3)));
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
  extern spydr_cube,imnum;
  extern gui_realized;
  
  pyk,swrite(format="y_parm_update('binsize',%f)",float(spydr_histbinsize));
  pyk,swrite(format="y_parm_update('nlevs',%d)",long(spydr_nlevs));
  pyk,swrite(format="y_parm_update('pixsize',%f)",float(spydr_pixsize(imnum)));
  pyk,swrite(format="y_parm_update('boxsize',%d)",long(spydr_boxsize));
  pyk,swrite(format="y_parm_update('saturation',%f)",float(spydr_saturation));
  pyk,swrite(format="y_parm_update('airmass',%f)",float(spydr_airmass));
  pyk,swrite(format="y_parm_update('wavelength',%f)",float(spydr_wavelength(imnum)));
  pyk,swrite(format="y_parm_update('teldiam',%f)",float(spydr_teldiam));
  pyk,swrite(format="y_parm_update('zero_point',%f)",float(spydr_zero_point));
  pyk,swrite(format="y_parm_update('cobs',%f)",float(spydr_cobs));
  pyk,swrite(format="y_parm_update('strehl_aper_radius',%f)",float(spydr_strehlmask));
  pyk,swrite(format="y_set_checkbutton('compute_strehl',%d)",long(compute_strehl));
  pyk,swrite(format="glade.get_widget('plugins').set_active(%d)",spydr_showplugins);
  if (imnum) pyk,swrite(format="y_set_imnum_visibility(1,%d)",dimsof(spydr_cube)(4));
  //  usleep,100;
  pyk,swrite(format="y_set_checkbutton('output_magnitudes',%d)",long(output_magnitudes));
  pyk,swrite(format="y_set_cmincmax(%f,%f,%f,0)",float(cmin),float(cmax),float(cmax-cmin)/100.);
  gui_realized=1;
}


func imchange_update(void)
{
  extern imnum;
  
  pyk,swrite(format="y_parm_update('pixsize',%f)",float(spydr_pixsize(imnum)));
  pyk,swrite(format="y_parm_update('wavelength',%f)",float(spydr_wavelength(imnum)));
  //  usleep,100;
  pyk,swrite(format="y_parm_update('zero_point',%f)",float(spydr_zero_point));
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
  cur = mouse_nowait(wid);
  if (cur==[]) return;
  cur = long(cur);
  cur(1:2) = cur(1:2)+1; //ceil
  return cur;
}
  

stop_zoom=0;
func spydr_clean(void)
{
  extern spydr_imname,spydr_imname4title;
  extern spydr_im,spydr_dims,cmin,cmax;
  extern spydr_cube,imnum;
  extern spydr_wavelength,spydr_pixsize;
  extern spydr_fh,x1,x2,y1,y2;
  
  /*
    winkill,spydr_wins(1);
  winkill,spydr_wins(2);
  winkill,spydr_wins(3);
  */
  stop_zoom=1;
  spydr_imname=spydr_imname4title=spydr_im=spydr_dims=spydr_cube=imnum=\
    spydr_fh=x1=x2=y1=y2=[];
}


func disp_zoom(void)
{
  extern from_disp,stop_zoom;

  if (stop_zoom) {
    stop_zoom=0;
    return;
  }
  
  cur = get_cursor();

  if ( (cur==[]) || (from_disp==3) ) { // not in correct window
    after,0.05,disp_zoom;
    return;
  }
    
  if (allof(prevxy==cur(1:2)) && (prevz==rad4zoom)) {  // same positon as before
    after,0.05,disp_zoom;
    return;
  }

  sys = cur(3);
  if (sys!=0) {

    i = clip(cur(1),1,spydr_dims(2));
    j = clip(cur(2),1,spydr_dims(3));
    pyk,swrite(format="y_set_xyz('%d','%d','%4.7g')",\
               i,j,float(spydr_im(i,j)));

    local_rad=5;
    x1 = clip(i-local_rad,1,spydr_dims(2));
    x2 = clip(i+local_rad,1,spydr_dims(2));
    y1 = clip(j-local_rad,1,spydr_dims(3));
    y2 = clip(j+local_rad,1,spydr_dims(3));
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
    else if (x2>spydr_dims(2)) { x2=spydr_dims(2); x1=x2-(2*rad4zoom+1); }      

    if (y1<1) { y1=1; y2=y1+(2*rad4zoom+1); }
    else if (y2>spydr_dims(3)) { y2=spydr_dims(3); y1=y2-(2*rad4zoom+1); }      

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
  after,0.05,disp_zoom;
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
               " e:   Adjust min and max cut to 10% and 99.9% ","      of distribution",
               " E:   Reset min and max cut to min and max ","      of <b>visible region</b>",
               " n/p: Next/prevous image",
               " s:   Sigma filter displayed image",
               " -/+: Decrease/Increase zoom factor in zoom window",
               " ?:   This help","</span>"];
  write,format="%s\n",help_text;
  pyk_info_w_markup,help_text;
}


func strehl_convert(sfrom,wfrom,wto)
{
  return exp(wfrom^2.*log(sfrom)/wto^2.)
}


func set_imnum(nn)
{
  extern spydr_im,spydr_cube,imnum;
  extern gui_realized;

  if (nn==imnum) return;
  
  imnum = nn;
  spydr_im=spydr_cube(,,imnum);
  //  if (gui_realized) pyk,swrite(format="y_parm_update('imnum',%d)",long(imnum));
}


func spydr_sigmafilter(void)
{
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

  write,format="\rReading %s",imname;
  
  im = fits_read(imname,fh);
  if (numberof(im)==0) {
    // try next hdu (e.g. niri)
    im = fits_read(imname,fh,hdu=2);
  }
  if (numberof(im)==0) error,imname+"found, but no data";

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
  wavl = 0.3;
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
  extern spydr_pixsize;

  if (imnum) spydr_pixsize(imnum) = value;
  else spydr_pixsize = value;
}


func spydr_set_wavelength(value)
{
  extern spydr_wavelength,imnum;

  if (imnum) spydr_wavelength(imnum) = value;
  else spydr_wavelength = value;
}


func figure_image_pixsize(fh)
{
  pixsize = 1.000;
  if (fits_get(fh,"INSTRUME")=="NICI") return 0.018;
  else return pixsize;
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


//=======================
// MAIN ROUTINE
//=======================

func spydr(image)
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
  extern spydr_imname,spydr_imname4title;
  extern spydr_im,spydr_dims,cmin,cmax;
  extern spydr_cube,imnum;
  extern spydr_wavelength,spydr_pixsize;
  extern spydr_fh;
  extern xcut, ycut;
  
  spydr_cube=[];
  imnum=0;
  xcut=ycut=0;
  spydr_get_available_windows;
  
  if (structof(image)==string) {  // filename, read it
    // expand image name in case of wild cards
    spydr_imname = findfiles(image(1));
    if (spydr_imname==[]) error,swrite(format="Can not find %s\n",image(1));
    for (i=2;i<=numberof(image);i++) grow,spydr_imname,findfiles(image(i));
    is_there = array(0,numberof(spydr_imname));
    for (i=1;i<=numberof(spydr_imname);i++) {
      if (noneof(findfiles(spydr_imname(i)))) {
        write,format="Warning: Can not find %s\n",spydr_imname(i);
      } else is_there(i)=1;
    }
    if (sum(is_there)==0) error,"Can not find any of the images";
    spydr_imname = spydr_imname(where(is_there));
    
    // read out first image:
    spydr_im = spydr_fits_read(spydr_imname(1),fh);

    spydr_wavelength = figure_image_wavelength(fh);
    spydr_pixsize = figure_image_pixsize(fh);
    
    if (dimsof(spydr_im)(1)==3) {
      // we're dealing with a data cube.
      spydr_cube = spydr_im;
      set_imnum,1;
      spydr_pixsize = array(spydr_pixsize,dimsof(spydr_cube)(4));
      spydr_wavelength = array(spydr_wavelength,dimsof(spydr_cube)(4));
      spydr_imname = image(1)+swrite(format=" %d",indgen(dimsof(spydr_cube)(4)));
      // spydr_im=spydr_cube(,,1);
    } else if (numberof(spydr_imname)>1) {
      // several images. read the others (note we can't have
      // this *and* a datacube
      spydr_cube = spydr_im(,,-);
      for (i=2;i<=numberof(spydr_imname);i++) {
        im=spydr_fits_read(spydr_imname(i),fh);
        if (anyof(dimsof(im)!=dimsof(spydr_im))) \
            error,"\nSPYDR can only deal with images of the same size";
        grow,spydr_cube,im;
        grow,spydr_wavelength,figure_image_wavelength(fh);
        grow,spydr_pixsize,figure_image_pixsize(fh);
      }
      set_imnum,1;
    }
  } else {
    if (dimsof(image)(1)==3) { // image cube
      eq_nocopy,spydr_cube,image;
      set_imnum,1;
      //spydr_im=spydr_cube(,,1);
      spydr_wavelength = array(spydr_wavelength,dimsof(image)(4));
      spydr_pixsize = array(spydr_pixsize,dimsof(image)(4));
      spydr_imname = array("image",dimsof(image)(4));
    } else { // 2d image
      eq_nocopy,spydr_im,image;  // copy image
      spydr_imname = "image";
    }
  }
  spydr_im = float(spydr_im);
  spydr_dims = dimsof(spydr_im);
  cmin = min(spydr_im);
  cmax = max(spydr_im);

  spydr_imname4title=[];
  for (i=1;i<=numberof(spydr_imname);i++) {
    fn = strtok(spydr_imname(i),"/",20);
    grow,spydr_imname4title,escapechar(fn(where(fn))(0));
  }
  
  // binsize=1 if image=integers, 0 else.
  // if 0, use nbin in hist calculation
  if (!spydr_histbinsize) spydr_histbinsize = (max(abs(spydr_im)%1)==0?1:0);
  
  // span the python process, and hook to existing _tyk_proc (see pyk.i)
  if (!_pyk_proc) _pyk_proc = spawn(pyk_cmd, _pyk_callback);
  else {
    // there's already a GUI around. hence we're not going to receive
    // a signal from python to bring up windows and display. we have
    // to init the display here:
    gui_update;
    disp_cpc;
    spydr_disp;
    plot_histo;
  }
  write,"\rSPYDR ready                                                    ";  
}

func pyk_flush(void)
{
  pyk,"yo2py_flush";
  after,1.,pyk_flush;
}


// when called from the command line:
arg     = get_argv();

spydr_context = "called_from_session";
if (numberof(arg)>=4) spydr_context="called_from_shell";
spydr_dpi = swrite(format="%d",spydr_defaultdpi);

tmppath = find_in_path("../python/spydr.py",takefirst=1);
if (is_void(tmppath)) error,"Can't find python/spydr.py in yorick path";
spydrtop = dirname(dirname(tmppath));

// spawned gtk interface
python_exec = spydrtop+"/python/spydr.py";
pyk_cmd=[python_exec,spydrtop,spydr_context,spydr_dpi];

if (numberof(arg)>=4) spydr,arg(4:);

pyk_flush;
