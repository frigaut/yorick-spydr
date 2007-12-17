#!/usr/bin/env python
# spydr.py
# 
# This file is part of spydr, an image viewer/data analysis tool
#
# $Id: spydr.py,v 1.3 2007-12-17 20:54:47 frigaut Exp $
#
# Copyright (c) 2007, Francois Rigaut
#
# This program is free software; you can redistribute it and/or  modify it
# under the terms of the GNU General Public License  as  published  by the
# Free Software Foundation; either version 2 of the License,  or  (at your
# option) any later version.
#
# This program is distributed in the hope  that  it  will  be  useful, but
# WITHOUT  ANY   WARRANTY;   without   even   the   implied   warranty  of
# MERCHANTABILITY or  FITNESS  FOR  A  PARTICULAR  PURPOSE.   See  the GNU
# General Public License for more details (to receive a  copy  of  the GNU
# General Public License, write to the Free Software Foundation, Inc., 675
# Mass Ave, Cambridge, MA 02139, USA).
# 
# $Log: spydr.py,v $
# Revision 1.3  2007-12-17 20:54:47  frigaut
# - added set/unset debug of yorick/python communication in GUI help menu
# - gotten rid of usleep calls and replaced by flush of pipe every seconds
#   (as for yao)
# - added debug from python side (set pyk_debug)
#
# Revision 1.2  2007/12/13 13:43:27  frigaut
# - added license headers in all files
# - added LICENSE
# - slightly modified Makefile
# - updated info
# - bumped to 0.5.1
#
#

import gtk
import gtk.glade
import sys
import gobject
import pango
import os, fcntl, errno

class spydr:
   
   def destroy(self, wdg, data=None):
      self.py2yo('quit')
      gtk.main_quit()
      
   def __init__(self,spydrtop,spydr_context,spydr_dpi):
      self.spydrtop = spydrtop
      self.spydr_context = spydr_context
      self.spydr_dpi = spydr_dpi
      self.usercmd = 'STOP'
      
      # callbacks and glade UI
      dic = {
         #'on_about_activate': self.on_about_activate,
         'on_debug_toggled': self.on_debug_toggled,
         'on_quit_activate' : self.on_quit_activate,
         'on_window1_map_event': self.on_window1_map,
         'on_drawingarea1_enter_notify_event': self.on_drawingarea1_enter_notify_event,
         'on_drawingarea1_leave_notify_event': self.on_drawingarea1_leave_notify_event,
         'on_cmin_value_changed': self.on_cmin_value_changed,
         'on_cmax_value_changed': self.on_cmax_value_changed,
         'on_cmincmax_toggled': self.on_cmincmax_toggled,
         'on_colors_value_changed': self.on_colors_value_changed,
         'on_tv_pressed': self.on_tv_pressed,
         'on_contours_pressed': self.on_contours_pressed,
         'on_surface_pressed': self.on_surface_pressed,
         'on_nlevs_value_changed': self.on_nlevs_value_changed,
         'on_contours_plus_tv_toggled': self.on_contours_plus_tv_toggled,
         'on_contours_filled_toggled': self.on_contours_filled_toggled,
         'on_shades_toggled': self.on_shades_toggled,
         'on_rebin_value_changed': self.on_rebin_value_changed,
         'on_histogram_clicked': self.on_histogram_clicked,
         'on_unzoom_clicked': self.on_unzoom_clicked,
         'on_limits_clicked': self.on_limits_clicked,
         'on_cut_clicked': self.on_cut_clicked,
         'on_azimuth_value_changed': self.on_azimuth_value_changed,
         'on_elevation_value_changed': self.on_elevation_value_changed,
         'on_plugins_toggled' : self.on_plugins_toggled,
         'on_do_psf_fit_clicked': self.on_do_psf_fit_clicked,
         'on_do_psf_fit2_clicked': self.on_do_psf_fit2_clicked,
         'on_pixsize_value_changed': self.on_pixsize_value_changed,
         'on_boxsize_value_changed': self.on_boxsize_value_changed,
         'on_saturation_value_changed': self.on_saturation_value_changed,
         'on_airmass_value_changed': self.on_airmass_value_changed,
         'on_wavelength_value_changed': self.on_wavelength_value_changed,
         'on_zero_point_value_changed': self.on_zero_point_value_changed,
         'on_teldiam_value_changed': self.on_teldiam_value_changed,
         'on_cobs_value_changed': self.on_cobs_value_changed,
         'on_compute_strehl_toggled': self.on_compute_strehl_toggled,
         'on_output_magnitudes_toggled': self.on_output_magnitudes_toggled,
         'on_invert_toggled': self.on_invert_toggled,
         'on_comboboxentry_changed': self.on_comboboxentry_changed,
         'on_comboboxentry2_changed': self.on_comboboxentry2_changed,
         'on_find_clicked': self.on_find_clicked,
         'on_spydr_help_activate': self.on_spydr_help_activate,
         'on_redisp_activate': self.on_redisp_activate,
         'on_rezoom_activate': self.on_rezoom_activate,
         'on_strehl_map_clicked': self.on_strehl_map_clicked,
         'on_imnum_value_changed': self.on_imnum_value_changed,
         'on_sigmafilter_clicked': self.on_sigmafilter_clicked,
         'on_strehl_aper_radius_value_changed': self.on_strehl_aper_radius_value_changed,
         'on_user_function1_clicked': self.on_user_function1_clicked,
         'on_user_function2_clicked': self.on_user_function2_clicked,
         'on_binsize_value_changed': self.on_binsize_value_changed,
         }
      
      self.glade = gtk.glade.XML(os.path.join(self.spydrtop,'glade/spydr.glade')) 
      self.window = self.glade.get_widget('window1')
      # handle destroy event
      if (self.window):
         self.window.connect('destroy', self.destroy)
      self.glade.signal_autoconnect(dic)

      # set stdin non blocking, this will prevent readline to block
      fd = sys.stdin.fileno()
      flags = fcntl.fcntl(fd, fcntl.F_GETFL)
      fcntl.fcntl(fd, fcntl.F_SETFL, flags | os.O_NONBLOCK)
      
      # add stdin to the event loop (yorick input pipe by spawn)
      gobject.io_add_watch(sys.stdin,gobject.IO_IN|gobject.IO_HUP,self.yo2py,None)

      # update parameters from yorick:
      self.py2yo('gui_update')

      #self.glade.get_widget('wfs_and_dms').hide()
      ebox = self.glade.get_widget('eventbox2')
      ebox.connect('key-press-event',self.on_eventbox2_key_press)

      # set size of graphic areas:
      dpi = spydr_dpi
      dsx = int(600.*dpi/100)+5
      dsy = int(600.*dpi/100)+25
      self.glade.get_widget('drawingarea1').set_size_request(dsx,dsy)
      dsx = int(600.*dpi/100)+5
      dsy = int(310.*dpi/100)+25
      self.glade.get_widget('drawingarea3').set_size_request(dsx,dsy)
      self.pyk_debug=0
      
      # run
      gtk.main()

   doing_zoom=0
   done_init=0
      
   #def on_about_activate(self,wdg):
   #   dialog = self.glade.get_widget('aboutdialog')
   #   dialog.run()
   #   dialog.hide()

   #
   # Yorick to Python Wrapper Functions
   #

   def y_parm_update(self,name,val):
      self.glade.get_widget(name).set_value(val)

   def y_text_parm_update(self,name,txt):
      self.glade.get_widget(name).set_text(txt)

   def y_set_checkbutton(self,name,val):
      self.glade.get_widget(name).set_active(val)

   def y_set_xyz(self,x,y,z):
      self.glade.get_widget('xvalue').set_text(x)
      self.glade.get_widget('yvalue').set_text(y)
      self.glade.get_widget('zvalue').set_text(z)

   def y_set_imnum_visibility(self,vis,numim):
      if (vis):
         self.glade.get_widget('imnum_label').show()
         self.glade.get_widget('imnum').show()
         self.glade.get_widget('imnum').set_range(1,numim)
      else:
         self.glade.get_widget('imnum_label').hide()
         self.glade.get_widget('imnum').hide()

   def y_set_user_function1_name(self,txt):
      self.glade.get_widget('user_function1').set_label(txt)
         
   def y_set_user_function2_name(self,txt):
      self.glade.get_widget('user_function2').set_label(txt)
         
   def pyk_status_push(self,id,txt):
      self.glade.get_widget('statusbar').push(id,txt)
      
   def pyk_status_pop(self,id):
      self.glade.get_widget('statusbar').pop(id)
      
   def y_set_cmincmax(self,cmin,cmax,incr,only_values):
      if (only_values!=1):
         self.glade.get_widget('cmin').set_range(cmin,cmax)
         self.glade.get_widget('cmax').set_range(cmin,cmax)
      self.glade.get_widget('cmin').set_value(cmin)
      self.glade.get_widget('cmax').set_value(cmax)
      self.glade.get_widget('cmin').set_increments(incr,incr)
      self.glade.get_widget('cmax').set_increments(incr,incr)
      
   def pyk_error(self,msg):
      dialog = gtk.MessageDialog(type=gtk.MESSAGE_ERROR,buttons=gtk.BUTTONS_OK,message_format=msg)
      dialog.run()
      dialog.destroy()

   def pyk_info(self,msg):
      dialog = gtk.MessageDialog(type=gtk.MESSAGE_INFO,buttons=gtk.BUTTONS_OK,message_format=msg)
      dialog.run()
      dialog.destroy()

   def pyk_info_w_markup(self,msg):
      dialog = gtk.MessageDialog(type=gtk.MESSAGE_INFO,buttons=gtk.BUTTONS_OK)
      dialog.set_markup(msg)
#      dialog.set_size_request(600,-1)
      dialog.run()
      dialog.destroy()

   def pyk_warning(self,msg):
      dialog = gtk.MessageDialog(type=gtk.MESSAGE_WARNING,buttons=gtk.BUTTONS_OK,message_format=msg)
      dialog.run()
      dialog.destroy()
      
   def on_debug_toggled(self,wdg):
      if (wdg.get_active()):
         self.pyk_debug=1
         self.py2yo("pyk_set pyk_debug 1")
      else:
         self.pyk_debug=0
         self.py2yo("pyk_set pyk_debug 0")

   def on_comboboxentry_changed(self,wdg):
      itt = wdg.get_active_text()
      if (itt=="linear"):
         self.py2yo('pyk_set spydr_itt 1')
      elif (itt=="sqrt"):
         self.py2yo('pyk_set spydr_itt 2')
      elif (itt=="square"):
         self.py2yo('pyk_set spydr_itt 3')
      elif (itt=="log"):
         self.py2yo('pyk_set spydr_itt 4')
      self.py2yo('spydr_lut')
      self.py2yo('spydr_disp')

   def on_comboboxentry2_changed(self,wdg):
      self.py2yo('pyk_set spydr_funtype "%s"' % wdg.get_active_text())
      
   def on_invert_toggled(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_invertlut %d' % wdg.get_active())
         self.py2yo('spydr_lut')

         
   def on_plugins_toggled(self,wdg):
      show_state = self.glade.get_widget('plugins').get_active()
#      self.py2yo('write show_state=%d' % show_state)
      if (show_state):
         try:
            s = self.size
         except:
            s = 0
         self.size = self.window.get_size()
         self.glade.get_widget('plugins_pane').show()
         if (s):
            self.window.resize(s[0],s[1])
      else:
         s = self.size
         self.size = self.window.get_size()
         self.glade.get_widget('plugins_pane').hide()
         self.window.resize(s[0],s[1])

   def on_sigmafilter_clicked(self,wdg):
      self.py2yo('spydr_sigmafilter')

   def on_user_function1_clicked(self,wdg):
      self.py2yo('user_function1')
      
   def on_user_function2_clicked(self,wdg):
      self.py2yo('user_function2')

   def on_do_psf_fit_clicked(self,wdg): # one pass
      self.py2yo('yfwhm spydr_im 1')
      
   def on_do_psf_fit2_clicked(self,wdg): # multiple pass
      self.py2yo('yfwhm spydr_im 0')

   def on_find_clicked(self,wdg):
      find_fwhm = self.glade.get_widget('find_fwhm').get_value()
      find_threshold = self.glade.get_widget('find_threshold').get_value()
      find_roundlim = self.glade.get_widget('find_roundlim').get_value()
      find_sharplow = self.glade.get_widget('find_sharplow').get_value()
      find_sharphigh = self.glade.get_widget('find_sharphigh').get_value()
      self.py2yo('spydr_find %f %f %f %f %f' % \
             (find_fwhm,find_threshold,find_roundlim,find_sharplow,find_sharphigh))

   def on_strehl_map_clicked(self,wdg):
      self.py2yo('spydr_strehl_map')
      
   def on_quit_activate(self,*args):
      if (self.spydr_context=='called_from_shell'):
         self.py2yo('quit')
      else:
         self.py2yo('spydr_clean')
      raise SystemExit

   def on_azimuth_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_azimuth %f' % self.glade.get_widget('azimuth').get_value())
         self.py2yo('spydr_disp')
         
   def on_elevation_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_elevation %f' % self.glade.get_widget('elevation').get_value())
         self.py2yo('spydr_disp')

   def on_binsize_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_histbinsize %f' % self.glade.get_widget('binsize').get_value())

   def on_pixsize_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('spydr_set_pixsize %f' % self.glade.get_widget('pixsize').get_value())
      
   def on_boxsize_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_boxsize %d' % self.glade.get_widget('boxsize').get_value())
         
   def on_saturation_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_saturation %f' % self.glade.get_widget('saturation').get_value())
         
   def on_airmass_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_airmass %f' % self.glade.get_widget('airmass').get_value())

   def on_wavelength_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('spydr_set_wavelength %f' % self.glade.get_widget('wavelength').get_value())
   
   def on_zero_point_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_zero_point %f' % self.glade.get_widget('zero_point').get_value())

   def on_teldiam_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_teldiam %f' % self.glade.get_widget('teldiam').get_value())

   def on_cobs_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_cobs %f' % self.glade.get_widget('cobs').get_value())

   def on_strehl_aper_radius_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_strehlmask %f' % self.glade.get_widget('strehl_aper_radius').get_value())
         
   def on_compute_strehl_toggled(self,wdg):
      self.py2yo('pyk_set compute_strehl %d' % wdg.get_active())
      self.glade.get_widget('wavelength_label').set_sensitive(wdg.get_active())
      self.glade.get_widget('wavelength').set_sensitive(wdg.get_active())
      self.glade.get_widget('teldiam_label').set_sensitive(wdg.get_active())
      self.glade.get_widget('teldiam').set_sensitive(wdg.get_active())
      self.glade.get_widget('cobs_label').set_sensitive(wdg.get_active())
      self.glade.get_widget('cobs').set_sensitive(wdg.get_active())
      self.glade.get_widget('strehl_aper_radius_label').set_sensitive(wdg.get_active())
      self.glade.get_widget('strehl_aper_radius').set_sensitive(wdg.get_active())
         
   def on_output_magnitudes_toggled(self,wdg):
      self.glade.get_widget('zero_point_label').set_sensitive(wdg.get_active())
      self.glade.get_widget('zero_point').set_sensitive(wdg.get_active())
      
   def on_unzoom_clicked(self,wdg):
      self.py2yo('unzoom')
      
   def on_histogram_clicked(self,wdg):
      self.py2yo('plot_histo')

   def on_limits_clicked(self,wdg):
      self.py2yo('do_limits')
      
   def on_cut_clicked(self,wdg):
      self.py2yo('plot_cut')

   def on_cmincmax_toggled(self,wdg):
      self.py2yo('pyk_set zoom_cmincmax %d' % wdg.get_active())
      
   def on_cmin_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set cmin %f' % self.glade.get_widget('cmin').get_value())
         self.py2yo('spydr_disp')

   def on_cmax_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set cmax %f' % self.glade.get_widget('cmax').get_value())
         self.py2yo('spydr_disp')

   def on_colors_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('spydr_lut %d' % self.glade.get_widget('colors').get_value())
         self.glade.get_widget('invert').set_active(0)


   def on_tv_pressed(self,wdg):
      self.glade.get_widget('contours_plus_tv').set_sensitive(0)
      self.glade.get_widget('contours_filled').set_sensitive(0)
      self.glade.get_widget('shades').set_sensitive(0)
      self.glade.get_widget('azimuth_label').hide()
      self.glade.get_widget('azimuth').hide()
      self.glade.get_widget('elevation_label').hide()
      self.glade.get_widget('elevation').hide()
      self.glade.get_widget('nlevs_label').hide()
      self.glade.get_widget('nlevs').hide()
      if (self.done_init):
         self.glade.get_widget('contours_plus_tv').set_active(0)
         self.glade.get_widget('contours_filled').set_active(0)
         self.py2yo('switch_disp 1') # 1 is tv
         self.py2yo('spydr_disp')
         
   def on_contours_pressed(self,wdg):
      self.glade.get_widget('contours_plus_tv').set_sensitive(1)
      self.glade.get_widget('contours_filled').set_sensitive(1)
      self.glade.get_widget('shades').set_sensitive(0)
      self.glade.get_widget('azimuth_label').hide()
      self.glade.get_widget('azimuth').hide()
      self.glade.get_widget('elevation_label').hide()
      self.glade.get_widget('elevation').hide()
      self.glade.get_widget('nlevs_label').show()
      self.glade.get_widget('nlevs').show()
      if (self.done_init):
         self.py2yo('switch_disp 2') # 2 is contour
         self.py2yo('spydr_disp')

   def on_surface_pressed(self,wdg):
      self.glade.get_widget('contours_plus_tv').set_sensitive(0)
      self.glade.get_widget('contours_filled').set_sensitive(0)
      self.glade.get_widget('shades').set_sensitive(1)
      self.glade.get_widget('contours_plus_tv').set_active(0)
      self.glade.get_widget('contours_filled').set_active(0)
      self.glade.get_widget('azimuth_label').show()
      self.glade.get_widget('azimuth').show()
      self.glade.get_widget('elevation_label').show()
      self.glade.get_widget('elevation').show()
      self.glade.get_widget('nlevs_label').hide()
      self.glade.get_widget('nlevs').hide()
      if (self.done_init):
         self.py2yo('switch_disp 3') # 3 is surface
         self.py2yo('spydr_disp')

   def on_contours_filled_toggled(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_filled %d' % wdg.get_active())
         self.py2yo('spydr_disp')
         if (wdg.get_active()):
            self.glade.get_widget('contours_plus_tv').set_active(0)
      
   def on_contours_plus_tv_toggled(self,wdg):
      if (self.done_init):
         if (wdg.get_active()):
            self.py2yo('switch_disp 4') # 4 is contour+tv
            self.glade.get_widget('contours_filled').set_active(0)
         else:
            self.py2yo('switch_disp 2') # 2 is contour
         self.py2yo('spydr_disp')

   def on_shades_toggled(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_shades %d' % wdg.get_active())
         self.py2yo('spydr_disp')

   def on_rebin_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('spydr_rebin %d' % self.glade.get_widget('rebin').get_value())
         self.py2yo('spydr_disp')
      
         
   def on_nlevs_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_nlevs %d' % self.glade.get_widget('nlevs').get_value())
         self.py2yo('spydr_disp')

   def on_imnum_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('set_imnum %d' % self.glade.get_widget('imnum').get_value())
         self.py2yo('imchange_update')
         self.py2yo('spydr_disp')

   def on_window1_map(self,wdg,*args):
      drawingarea = self.glade.get_widget('drawingarea1')
      mwid1 = drawingarea.window.xid;
      drawingarea = self.glade.get_widget('drawingarea2')
      mwid2 = drawingarea.window.xid;
      drawingarea = self.glade.get_widget('drawingarea3')
      mwid3 = drawingarea.window.xid;
      self.py2yo('spydr_win_init %d %d %d' % (mwid1,mwid2,mwid3))

   def on_drawingarea1_enter_notify_event(self,wdg,*args):
      self.glade.get_widget('eventbox2').grab_focus()
      if (self.doing_zoom==0):
         self.py2yo('disp_zoom')
         self.doing_zoom=1
      #self.set_cursor_busy(0)

   def on_drawingarea1_leave_notify_event(self,wdg,*args):
      if (self.doing_zoom==1):
         self.py2yo('pyk_set stop_zoom 1')
         self.doing_zoom=0
#      self.set_cursor_busy(1)

   def on_spydr_help_activate(self,wdg):
      self.py2yo('spydr_shortcut_help')

   def on_redisp_activate(self,wdg):
      self.py2yo('spydr_disp')

   def on_rezoom_activate(self,wdg):
      self.py2yo('disp_zoom')

   def on_eventbox2_key_press(self,wdg,event):
      if (event.string=='?'):
         self.py2yo('spydr_shortcut_help')
      if (event.string=='f'):
         self.py2yo('fit_gaussian_1d')
      if (event.string=='c'):
         self.py2yo('plot_cut')
      if (event.string=='r'):
         self.py2yo('plot_radial')
      if (event.string=='X'):
         self.py2yo('toggle_xcut')
      if (event.string=='Y'):
         self.py2yo('toggle_ycut')
      if (event.string=='x'):
         self.py2yo('plot_xcut')
      if (event.string=='y'):
         self.py2yo('plot_ycut')
      if (event.string=='h'):
         self.py2yo('plot_histo')
      if (event.string=='e'):
         self.py2yo('disp_cpc')
      if (event.string=='E'):
         self.py2yo('disp_cpc 0')
      if (event.string=='n'):
         n = self.glade.get_widget('imnum').get_value()
         self.glade.get_widget('imnum').set_value(n+1)
      if (event.string=='p'):
         n = self.glade.get_widget('imnum').get_value()
         self.glade.get_widget('imnum').set_value(n-1)
      if (event.string=='s'):
         self.py2yo('spydr_sigmafilter')
      if (event.string=='-'):
         self.py2yo('rad4zoom_incr')
      if (event.string=='=') or (event.string=='+'):
         self.py2yo('rad4zoom_decr')
      return True

   #
   # minimal wrapper for yorick/python communication
   #
   
   def yo2py_flush(self):
      sys.stdin.flush()
   
   def py2yo(self,msg):
      # sends string command to yorick's eval
      sys.stdout.write(msg+'\n')
      sys.stdout.flush()
   
   def yo2py(self,cb_condition,*args):
      if cb_condition == gobject.IO_HUP:
         raise SystemExit, "lost pipe to yorick"
      # handles string command from yorick
      # note: inidividual message needs to end with /n for proper ungarbling
      while 1:
         try:
            msg = sys.stdin.readline()
            msg = "self."+msg
            if (self.pyk_debug): 
               sys.stderr.write("Python stdin:"+msg)
            exec(msg)
         except IOError, e:
            if e.errno == errno.EAGAIN:
               # the pipe's empty, good
               break
            # else bomb out
            raise SystemExit, "yo2py unexpected IOError:" + str(e)
         except Exception, ee:
            raise SystemExit, "yo2py unexpected Exception:" + str(ee)
         return True

   def set_cursor_busy(self,state):
      if state:
         self.window.window.set_cursor(gtk.gdk.Cursor(gtk.gdk.WATCH))
      else:
         self.window.window.set_cursor(gtk.gdk.Cursor(gtk.gdk.LEFT_PTR))
         
if len(sys.argv) != 4:
   print 'Usage: spydr.py path_to_spydr spydr_context'
   raise SystemExit

spydrtop = str(sys.argv[1])
spydr_context = str(sys.argv[2])
spydr_dpi = int(sys.argv[3])
top = spydr(spydrtop,spydr_context,spydr_dpi)
