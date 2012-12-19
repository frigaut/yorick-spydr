#!/usr/bin/env python2
# spydr.py
#
# This file is part of spydr, an image viewer/data analysis tool
#
# $Id: spydr.py,v 1.13 2010/04/15 02:56:02 frigaut Exp $
#
# Copyright (c) 2007, Francois Rigaut
#
# This program is free software; you can redistribute it and/or  modify it
# under the terms of the GNU General Public License  as  published  by the
# Free Software Foundation; either version 3 of the License,  or  (at your
# option) any later version.
#
# This program is distributed in the hope  that  it  will  be  useful, but
# WITHOUT  ANY   WARRANTY;   without   even   the   implied   warranty  of
# MERCHANTABILITY or  FITNESS  FOR  A  PARTICULAR  PURPOSE.   See  the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# $Log: spydr.py,v $
# Revision 1.13  2010/04/15 02:56:02  frigaut
#
# updated repo to 0.8.1
#
# Revision 1.12  2009/03/11 16:03:33  frigaut
# - patched (fixed?) the whole histogram thing. before, was
# crashing for image=cte. now ok.
# - increased the number of digit in GUI for cmin/cmax/binsize
# - bumped to version 0.8.0
#
# Revision 1.11  2008/02/12 13:58:43  frigaut
# changelog to version 0.7.7:
#
# - fixed a bug when spydr_lut is not 0 and one creates a new
#   window.
# - other minor bug fixes.
# - updated spydr man page
# - written and published web doc on maumae.
#
# Revision 1.10  2008/02/10 15:08:07  frigaut
# Version 0.7.6:
# - can now change the dpi on the fly. ctrl++ and ctrl+- will enlarge
#   or shrink the graphical areas. long time missing in yorick.
#   I have tried to make the window resizable, but it's a mess. Not
#   only in the management of events, but also in the policy: really,
#   only enlarging proportionally makes sense.
# - changed a bit the zoom behavior: now zoom is started once (the first
#   time the mouse enter drawingarea1), and does not stop from that point.
#   This is not ideal/economical (although disp_zoom returns immediately
#   if the mouse is not in the image window), but it has the advantage
#   of being sure the disp_zoom process does not spawn multiple instances
#   (recurrent issue with "after").
# - The menu items in the left menu bar are hidden/shown according to the
#   window size.
# - gotten rid of a few (unused) functions in spydr.i (the progressbar
#   and message functions) that were conflicting with other pyk instances.
# - there's now focus in and out functions that will reset the current
#   window to what it was before the focus was given to spydr. This is
#   convenient when one just want to popup a spydr window to look at an
#   image, and then come back to whatever one was doing without having to
#   execute a window,n command.
# - fixed a bug in disp_cpc. Now, when a "e"/"E" command is executed
#   while a subimage is displayed, the "e"/"E" applies to the displayed
#   subimage, not the whole image.
# - changed a bit the behavior of the lower graphical area: not the y
#   range is the same as the image zcuts (cmin/cmax).
# - fixed a small bug in get_subim (using floor/ceil instead of round
#   for the indices determination).
# - added "compact" keyword to the spydr function (when called from
#   within yorick).
# - clipping dpi values to [30,400].
# - spydr.py: went for a self autodic instead of an explicit
#   declaration of all functions.
# - implemented smoothing by _x2
# - implemented 1d linear fitting
#
# Revision 1.9  2008/02/02 04:49:21  frigaut
# many changes once more:
# - can now display graphes with X/Y axis in arcsec
# - cleaned up mode switching (tv/contours/surface). Now more reliable.
# - contour filled and tv switch survive a mode switching (before, were
#   reset)
# - limits are sticky between switch of mode (especially when switching
#   to contours)
# - when axis in arcsec is selected, gaussian fit is expresed in arcsec too.
# - added export to pdf, postscript, encapsulated postscript
# - added menu to pick color of contour lines
# - added menu to pick color of contour marks
# - implemented contour legends on plots
# - added menu to select position of contour legends
# - new functionality to compute distance between 2 points (see shortcut
#   "M" and "m").
# - rebin now works both ways (increasing and decreasing number of pixels)
# - added "hdu" command line keyword, and updated manpage.
# - added hist-equalize option to LUT
#
# this is version 0.7.3
#
# Revision 1.8  2008/01/29 21:23:46  frigaut
# - upgraded version 0.7.2
# - added "save as", "save" and export to jpeg and png menus/actions
#
# Revision 1.7  2008/01/25 03:03:49  frigaut
# - updated license or license text to GPLv3 in all files
#
# Revision 1.6  2008/01/24 15:05:17  frigaut
# - added "delete from stack" feature
# - some bugfix in psffit
#
# Revision 1.5  2008/01/23 21:11:22  frigaut
# - load of new things:
#
# New Features:
# - added a number of command line flags (see man page or spydr -h)
# - can now handle series of image of different sizes
# - can mix single image and cube
# - cmin and cmax are now set per image (sticky setting)
# - image titles are better handled
# - updated man page
# - new image can be opened from the GUI menu (filechooser, multiple
#   selection ok)
# - migrated to a spydrs structure, replaced many different variables, cleaner.
# - now opens the GUI even with no image argument (can use "open" from menu)
# - all errors are now also displayed as popups (critical quits yorick
#   when called from shell)
# - because some (of the more critical) errors can happen before python is
#   started, I had to use zenity for the popup window. New dependency.
# - added an "append" keyword to spydr. If set, the new image is appended
#   to the list of displayed image. The old ones are kept, and the total
#   number of image is ++
# - append is also available from the GUI menu
# - any action on displayed image can be null by using "help->refresh
#   display" (in particular, sigmafilter)
# - created "about" dialog.
# - added an "image" menu (with names of all images in stack). user can
#   select image form there.
# - added an "ops" (operation) menu. Can compute median, average, sum,
#   rms, min and max of cube.
# - small gui (without lower panel) form is called with --compact (-c)
#
# Bug fixes:
# - fixed path to find python and glade files
# - fixed path for configuration file
# - main routine re-written and much more robust and clean
# - (kind of) solved a issue where image got displayed several times
#   because of echo from setting cmin and cmax
# - fixed thibaut bug when closing window.
# - fixed "called_from_shell" when no image argument.
# - waiting for a doc for the user buttons, set to insivible.
# - waiting for a proper implementation of find, pane set to invisible.
#
#
# - bug: sometimes the next/previous image does not register
#
# Revision 1.4  2008/01/02 14:11:42  frigaut
# - better fit of graphical area in GUI
# - updated spec file
#
# Revision 1.3  2007/12/17 20:54:47  frigaut
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
      self.py2yo('spydr_quit')
      raise SystemExit
#      gtk.main_quit()

   def __init__(self,spydrtop,spydr_showlower,spydr_dpi,spydr_showplugins):
      self.spydrtop = spydrtop
      self.spydr_showlower = spydr_showlower
      self.spydr_defaultdpi = spydr_dpi
      self.spydr_dpi = spydr_dpi
      self.spydr_showplugins = spydr_showplugins
      self.usercmd = 'STOP'

      # callbacks and glade UI

      self.glade = gtk.glade.XML(os.path.join(self.spydrtop,'spydr.glade'))
      self.window = self.glade.get_widget('window1')
      # handle destroy event
      if (self.window):
         self.window.connect('destroy', self.destroy)
      self.glade.signal_autoconnect(self)

      # set stdin non blocking, this will prevent readline to block
      fd = sys.stdin.fileno()
      flags = fcntl.fcntl(fd, fcntl.F_GETFL)
      fcntl.fcntl(fd, fcntl.F_SETFL, flags | os.O_NONBLOCK)

      # add stdin to the event loop (yorick input pipe by spawn)
      gobject.io_add_watch(sys.stdin,gobject.IO_IN|gobject.IO_HUP,self.yo2py,None)

      # update parameters from yorick:
      #self.py2yo('gui_update')

      ebox = self.glade.get_widget('vbox3')
      ebox.connect('key-press-event',self.on_vbox3_key_press)

      # set size of graphic areas:
      self.drawingareas_size_allocate(spydr_dpi)

      self.pyk_debug=0
      self.win_init_done = 0
      self.currentdir=os.getcwd()
      self.currentsavedir=os.getcwd()
      self.imgroup=None
      self.current_image_menu=0
      self.current_image_saveas_name=None
      self.just_done_range=0
      self.next_to_all = 0

      if (spydr_showlower==0):
         if (spydr_dpi < 70):
            self.glade.get_widget('frame1').hide()
         if (spydr_dpi < 85):
            self.glade.get_widget('frame2').hide()
         self.glade.get_widget('table1').hide()
         self.glade.get_widget('drawingarea3').hide()
         self.glade.get_widget('togglelower').set_active(0)

      if (spydr_showplugins):
         self.glade.get_widget('plugins_pane').show()

      self.pyk_status_push(1,'Initializing...')

      # run
      gtk.main()

   doing_zoom=0
   done_init=0

   def on_about_activate(self,wdg):
      dialog = self.glade.get_widget('aboutdialog')
      dialog.run()
      dialog.hide()

   def on_window1_size_request(self,wdg,*arg):
      #  sys.stderr.write("PYTHON: window1 size = %d x %d\n" % wdg.get_size())
#      sys.stderr.write("PYTHON: vbox2 height = %s\n" % self.glade.get_widget('vbox2').get_allocation().height)
#      sys.stderr.write("PYTHON: zoom height = %s\n" % self.glade.get_widget('zoom').get_allocation().height)
#      sys.stderr.write("PYTHON: actions height = %s\n" % self.glade.get_widget('frame1').get_allocation().height)
#      sys.stderr.write("PYTHON: LUT height = %s\n" % self.glade.get_widget('frame2').get_allocation().height)
#      sys.stderr.write("PYTHON: table1 height = %s\n\n" % self.glade.get_widget('table1').get_allocation().height)

#      avail = self.glade.get_widget('vbox2').get_allocation().height
      tb = self.glade.get_widget('menubar1').get_allocation().height
      tb = tb+self.glade.get_widget('statusbar').get_allocation().height+10
#      sys.stderr.write("PYTHON: menuabar1+statusbar = %d\n\n" % tb)
      avail = wdg.get_size()[1]-tb
      h = self.glade.get_widget('zoom').get_allocation().height
      h = h + self.glade.get_widget('frame1').get_allocation().height
      if (h<avail):
         self.glade.get_widget('frame1').show()
      else:
         self.glade.get_widget('frame1').hide()
      h = h + self.glade.get_widget('frame2').get_allocation().height
      if (h<(avail)):
         self.glade.get_widget('frame2').show()
      else:
         self.glade.get_widget('frame2').hide()
      h = h + self.glade.get_widget('table1').get_allocation().height
      if (h<(avail)):
         self.glade.get_widget('table1').show()
      else:
         self.glade.get_widget('table1').hide()

#      sys.stderr.write("PYTHON: available = %d, sum = %d\n\n" % (avail,h))

   def drawingareas_size_allocate(self,dpi):
#      sys.stderr.write("PYTHON: new dpi = %d \n" % dpi)
      dsx = int(595.*dpi/100)+4
      dsy = int(596.*dpi/100)+25
      self.glade.get_widget('drawingarea1').set_size_request(dsx,dsy)
      dsx = int(595.*dpi/100)+4
      dsy = int(307.*dpi/100)+25
      self.glade.get_widget('drawingarea3').set_size_request(dsx,dsy)

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

   def y_set_user_function1_name(self,txt):
      self.glade.get_widget('user_function1').set_label(txt)

   def y_set_user_function2_name(self,txt):
      self.glade.get_widget('user_function2').set_label(txt)

   def pyk_status_push(self,id,txt):
      self.glade.get_widget('statusbar').push(id,txt)

   def pyk_status_pop(self,id):
      self.glade.get_widget('statusbar').pop(id)

   def y_set_lut(self,value):
#      if (self.done_init):
      self.glade.get_widget('colors').set_value(value)

   def y_set_invertlut(self,value):
#      if (self.done_init):
      self.glade.get_widget('invert').set_active(value)

   def y_set_itt(self,value):
#      if (self.done_init):
      self.glade.get_widget('itt').set_active(value)

   def y_set_cmincmax(self,cmin,cmax,incr,only_values):
      if (only_values!=1):
         pass
#         self.glade.get_widget('cmin').set_range(cmin,cmax)
#         self.glade.get_widget('cmax').set_range(cmin,cmax)
      self.glade.get_widget('cmin').set_increments(incr,incr)
      self.glade.get_widget('cmax').set_increments(incr,incr)
      self.glade.get_widget('cmin').set_value(cmin)
      self.glade.get_widget('cmax').set_value(cmax)

   def reset_image_menu(self):
      c = self.glade.get_widget('image_menu').get_children()
      for item in c:
         #sys.stderr.write("PYTHON: removing menu item =%s \n" % item.get_name())
         self.glade.get_widget('image_menu').remove(item)

   def add_to_image_menu(self,name,ind):
      item=gtk.MenuItem(label=name)
      item.set_name(name)
      item.connect("activate",self.on_image_menu_selection_done, ind)
      self.glade.get_widget('image_menu').append(item)
      item.show()


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

   def on_open_activate(self,wdg):
      chooser = gtk.FileChooserDialog(title='spydr open file',action=gtk.FILE_CHOOSER_ACTION_OPEN,buttons=(gtk.STOCK_CANCEL,gtk.RESPONSE_CANCEL,gtk.STOCK_OPEN,gtk.RESPONSE_OK))
      filter = gtk.FileFilter()
      filter.add_pattern('*.fits')
      filter.set_name('Fits files')
      chooser.add_filter(filter)
      chooser.set_select_multiple(1)
      chooser.set_current_folder(self.currentdir)
      res = chooser.run()
      if res == gtk.RESPONSE_OK:
         files=chooser.get_filenames()
         self.currentdir = chooser.get_current_folder()
         fs = ''
         for file in files:
            fs += '\"'+file+'\" '
         self.py2yo('spydr %s' % fs)
      chooser.destroy()

   def on_append_activate(self,wdg):
      chooser = gtk.FileChooserDialog(title='spydr open file',action=gtk.FILE_CHOOSER_ACTION_OPEN,buttons=(gtk.STOCK_CANCEL,gtk.RESPONSE_CANCEL,gtk.STOCK_OPEN,gtk.RESPONSE_OK))
      filter = gtk.FileFilter()
      filter.add_pattern('*.fits')
      filter.set_name('Fits files')
      chooser.add_filter(filter)
      chooser.set_select_multiple(1)
      chooser.set_current_folder(self.currentdir)
      res = chooser.run()
      if res == gtk.RESPONSE_OK:
         files=chooser.get_filenames()
         self.currentdir = chooser.get_current_folder()
         fs = ''
         for file in files:
            fs += '\"'+file+'\" '
         self.py2yo('pyk_set spydr_append 1')
         self.py2yo('spydr %s' % fs)
      chooser.destroy()

   def on_saveas_activate(self,wdg):
      chooser = gtk.FileChooserDialog(title='Save as...',action=gtk.FILE_CHOOSER_ACTION_SAVE,buttons=(gtk.STOCK_CANCEL,gtk.RESPONSE_CANCEL,gtk.STOCK_SAVE,gtk.RESPONSE_OK))
      filter = gtk.FileFilter()
      filter.add_pattern('*.fits')
      filter.set_name('Fits files')
      chooser.add_filter(filter)
      chooser.set_current_folder(os.path.abspath(self.currentsavedir))
      chooser.set_current_name(self.current_image_saveas_name)
      res = chooser.run()
      if res == gtk.RESPONSE_OK:
         file=chooser.get_filename()
         self.currentsavedir = chooser.get_current_folder()
         self.py2yo('spydr_saveas \"%s\"' % file)
      chooser.destroy()

   def on_save_activate(self,wdg):
      self.py2yo('spydr_save')

   def on_exportjpeg_activate(self,wdg):
      chooser = gtk.FileChooserDialog(title='Export as jpeg',action=gtk.FILE_CHOOSER_ACTION_SAVE,buttons=(gtk.STOCK_CANCEL,gtk.RESPONSE_CANCEL,gtk.STOCK_SAVE,gtk.RESPONSE_OK))
      filter = gtk.FileFilter()
      filter.add_pattern('*.jpg')
      filter.set_name('JPEG files')
      chooser.add_filter(filter)
      chooser.set_current_folder(os.path.abspath(self.currentsavedir))
      chooser.set_current_name(self.current_image_saveas_name+'.jpg')
      res = chooser.run()
      if res == gtk.RESPONSE_OK:
         file=chooser.get_filename()
         self.currentsavedir = chooser.get_current_folder()
         self.py2yo('spydr_exportjpeg \"%s\"' % file)
      chooser.destroy()

   def on_exportpng_activate(self,wdg):
      chooser = gtk.FileChooserDialog(title='Export as png',action=gtk.FILE_CHOOSER_ACTION_SAVE,buttons=(gtk.STOCK_CANCEL,gtk.RESPONSE_CANCEL,gtk.STOCK_SAVE,gtk.RESPONSE_OK))
      filter = gtk.FileFilter()
      filter.add_pattern('*.png')
      filter.set_name('PNG files')
      chooser.add_filter(filter)
      chooser.set_current_folder(os.path.abspath(self.currentsavedir))
      chooser.set_current_name(self.current_image_saveas_name+'.png')
      res = chooser.run()
      if res == gtk.RESPONSE_OK:
         file=chooser.get_filename()
         self.currentsavedir = chooser.get_current_folder()
         self.py2yo('spydr_exportpng \"%s\"' % file)
      chooser.destroy()

   def on_exportpdf_activate(self,wdg):
      chooser = gtk.FileChooserDialog(title='Export as pdf',action=gtk.FILE_CHOOSER_ACTION_SAVE,buttons=(gtk.STOCK_CANCEL,gtk.RESPONSE_CANCEL,gtk.STOCK_SAVE,gtk.RESPONSE_OK))
      filter = gtk.FileFilter()
      filter.add_pattern('*.pdf')
      filter.set_name('PDF files')
      chooser.add_filter(filter)
      chooser.set_current_folder(os.path.abspath(self.currentsavedir))
      chooser.set_current_name(self.current_image_saveas_name+'.pdf')
      res = chooser.run()
      if res == gtk.RESPONSE_OK:
         file=chooser.get_filename()
         self.currentsavedir = chooser.get_current_folder()
         self.py2yo('spydr_exportpdf \"%s\"' % file)
      chooser.destroy()

   def on_exportps_activate(self,wdg):
      chooser = gtk.FileChooserDialog(title='Export as ps',action=gtk.FILE_CHOOSER_ACTION_SAVE,buttons=(gtk.STOCK_CANCEL,gtk.RESPONSE_CANCEL,gtk.STOCK_SAVE,gtk.RESPONSE_OK))
      filter = gtk.FileFilter()
      filter.add_pattern('*.ps')
      filter.set_name('PS files')
      chooser.add_filter(filter)
      chooser.set_current_folder(os.path.abspath(self.currentsavedir))
      chooser.set_current_name(self.current_image_saveas_name+'.ps')
      res = chooser.run()
      if res == gtk.RESPONSE_OK:
         file=chooser.get_filename()
         self.currentsavedir = chooser.get_current_folder()
         self.py2yo('spydr_exportps \"%s\"' % file)
      chooser.destroy()

   def on_exporteps_activate(self,wdg):
      chooser = gtk.FileChooserDialog(title='Export as eps',action=gtk.FILE_CHOOSER_ACTION_SAVE,buttons=(gtk.STOCK_CANCEL,gtk.RESPONSE_CANCEL,gtk.STOCK_SAVE,gtk.RESPONSE_OK))
      filter = gtk.FileFilter()
      filter.add_pattern('*.eps')
      filter.set_name('EPS files')
      chooser.add_filter(filter)
      chooser.set_current_folder(os.path.abspath(self.currentsavedir))
      chooser.set_current_name(self.current_image_saveas_name+'.eps')
      res = chooser.run()
      if res == gtk.RESPONSE_OK:
         file=chooser.get_filename()
         self.currentsavedir = chooser.get_current_folder()
         self.py2yo('spydr_exporteps \"%s\"' % file)
      chooser.destroy()

   def on_plot_in_arcsec_toggled(self,wdg):
      self.py2yo('spydr_set_plot_in_arcsec %d' % self.glade.get_widget('plot_in_arcsec').get_active())

   def on_ccolor_toggled(self,wdg):
      data = self.glade.get_widget('ccolor').get_active()
      #sys.stderr.write("PYTHON: color = %s \n" % data.get_name())
      self.py2yo('set_spydr_ccolor \"%s\"' % data.get_name())

   def on_mcolor_toggled(self,wdg):
      data = self.glade.get_widget('mcolor').get_active()
      self.py2yo('set_spydr_mcolor \"%s\"' % data.get_name()[1:])

   def on_clabel_toggled(self,wdg):
      data = self.glade.get_widget('clabel').get_active()
      self.py2yo('set_spydr_clabel \"%s\"' % data.get_name())

   def on_cubemed_activate(self,wdg):
      self.py2yo('spydr_cubeops 1')

   def on_cubeavg_activate(self,wdg):
      self.py2yo('spydr_cubeops 2')

   def on_cubesum_activate(self,wdg):
      self.py2yo('spydr_cubeops 3')

   def on_cuberms_activate(self,wdg):
      self.py2yo('spydr_cubeops 4')

   def on_cubemin_activate(self,wdg):
      self.py2yo('spydr_cubeops 5')

   def on_cubemax_activate(self,wdg):
      self.py2yo('spydr_cubeops 6')

   def on_itt_changed(self,wdg):
      itt = wdg.get_active_text()
      if (itt=="linear"):
         self.py2yo('pyk_set spydr_itt 1')
      elif (itt=="sqrt"):
         self.py2yo('pyk_set spydr_itt 2')
      elif (itt=="square"):
         self.py2yo('pyk_set spydr_itt 3')
      elif (itt=="log"):
         self.py2yo('pyk_set spydr_itt 4')
      elif (itt=="histeq"):
         self.py2yo('pyk_set spydr_itt 5')
      self.py2yo('spydr_set_lut')
      self.py2yo('spydr_disp')

   def on_comboboxentry2_changed(self,wdg):
      self.py2yo('pyk_set spydr_funtype "%s"' % wdg.get_active_text())

   def on_invert_toggled(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_invertlut %d' % wdg.get_active())
         self.py2yo('spydr_set_lut')


   def on_plugins_toggled(self,wdg):
      show_state = self.glade.get_widget('plugins').get_active()
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
      self.py2yo('pyk_set spydr_showplugins %d' % show_state)

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
      self.py2yo('spydr_quit')
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
         #isup=self.glade.get_widget('togglelower').get_active()
         #if (isup):
         #   self.py2yo('plot_histo')

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

   def on_strehl_aper_diameter_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_strehlaper %f' % self.glade.get_widget('strehl_aper_diameter').get_value())

   def on_compute_strehl_toggled(self,wdg):
      self.py2yo('pyk_set compute_strehl %d' % wdg.get_active())
      self.glade.get_widget('wavelength_label').set_sensitive(wdg.get_active())
      self.glade.get_widget('wavelength').set_sensitive(wdg.get_active())
      self.glade.get_widget('teldiam_label').set_sensitive(wdg.get_active())
      self.glade.get_widget('teldiam').set_sensitive(wdg.get_active())
      self.glade.get_widget('cobs_label').set_sensitive(wdg.get_active())
      self.glade.get_widget('cobs').set_sensitive(wdg.get_active())
      self.glade.get_widget('strehl_aper_diameter_label').set_sensitive(wdg.get_active())
      self.glade.get_widget('strehl_aper_diameter').set_sensitive(wdg.get_active())

   def on_output_magnitudes_toggled(self,wdg):
      self.glade.get_widget('zero_point_label').set_sensitive(wdg.get_active())
      self.glade.get_widget('zero_point').set_sensitive(wdg.get_active())

   def on_unzoom_clicked(self,wdg):
      self.py2yo('unzoom')
      self.py2yo('limits')

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
         self.py2yo('set_cmin %f' % self.glade.get_widget('cmin').get_value())

   def on_cmax_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('set_cmax %f' % self.glade.get_widget('cmax').get_value())

   def on_colors_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('spydr_set_lut %d' % self.glade.get_widget('colors').get_value())
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
         #self.glade.get_widget('contours_plus_tv').set_active(0)
         #self.glade.get_widget('contours_filled').set_active(0)
         self.py2yo('switch_disp 1') # 1 is tv

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
      self.py2yo('pyk_set spydr_filled %d' % self.glade.get_widget('contours_filled').get_active())
      if (self.done_init):
         if (self.glade.get_widget('contours_plus_tv').get_active()):
            self.py2yo('switch_disp 4') # 4 is contour+tv
         else:
            self.py2yo('switch_disp 2') # 2 is contour

   def on_surface_pressed(self,wdg):
      self.glade.get_widget('contours_plus_tv').set_sensitive(0)
      self.glade.get_widget('contours_filled').set_sensitive(0)
      self.glade.get_widget('shades').set_sensitive(1)
      #self.glade.get_widget('contours_plus_tv').set_active(0)
      #self.glade.get_widget('contours_filled').set_active(0)
      self.glade.get_widget('azimuth_label').show()
      self.glade.get_widget('azimuth').show()
      self.glade.get_widget('elevation_label').show()
      self.glade.get_widget('elevation').show()
      self.glade.get_widget('nlevs_label').hide()
      self.glade.get_widget('nlevs').hide()
      if (self.done_init):
         self.py2yo('switch_disp 3') # 3 is surface

   def on_contours_filled_toggled(self,wdg):
      if (self.done_init):
         if (wdg.get_active()):
            if (self.glade.get_widget('contours_plus_tv').get_active()):
               self.glade.get_widget('contours_plus_tv').set_active(0)
         self.py2yo('pyk_set spydr_filled %d' % wdg.get_active())
         self.py2yo('spydr_disp')

   def on_contours_plus_tv_toggled(self,wdg):
      if (self.done_init):
         if (wdg.get_active()):
            if (self.glade.get_widget('contours_filled').get_active()):
               self.glade.get_widget('contours_filled').set_active(0)
            self.py2yo('switch_disp 4') # 4 is contour+tv
         else:
            self.py2yo('switch_disp 2') # 2 is contour

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
      #if (self.just_done_range):
      #   self.just_done_range=0
      #   return
      if (self.done_init):
         imnum = self.glade.get_widget('imnum').get_value()
         #sys.stderr.write("PYTHON: on_imnum_value_changed, imnum=%d \n" % imnum)
         # set yorick image #
         self.py2yo('set_imnum %d 1' % imnum)
         self.py2yo('imchange_update')
         self.glade.get_widget('rebin').set_value(0)

   def set_imnum(self,imnum,numim,vis):
      #sys.stderr.write("PYTHON: entering set_imnum with request %d\n" % imnum)
      if (self.done_init):
         if (vis):
            self.glade.get_widget('imnum').set_range(1,numim)
            #self.just_done_range=1
            self.glade.get_widget('imnum_label').set_text("image#(%d)" % numim)
            self.glade.get_widget('imnum_label').show()
            self.glade.get_widget('imnum').show()
         else:
            self.glade.get_widget('imnum_label').hide()
            self.glade.get_widget('imnum').hide()
         # update imnum widget value if needed
         current1 = self.glade.get_widget('imnum').get_value()
         #sys.stderr.write("PYTHON: current image=%d\n" % current1)
         if (current1!=imnum):
            self.glade.get_widget('imnum').set_value(imnum)

   def on_window1_map_event(self,wdg,*args):
      if (self.win_init_done): return
      drawingarea = self.glade.get_widget('drawingarea1')
      mwid1 = drawingarea.window.xid;
      drawingarea = self.glade.get_widget('drawingarea2')
      mwid2 = drawingarea.window.xid;
      drawingarea = self.glade.get_widget('drawingarea3')
      mwid3 = drawingarea.window.xid;
      # set size of drawingarea2, just once per session:
      dsx = int(183.*self.spydr_dpi/100)+4
      dsy = int(183.*self.spydr_dpi/100)+25
      self.glade.get_widget('drawingarea2').set_size_request(dsx,dsy)

      self.py2yo('spydr_win_init %d %d %d' % (mwid1,mwid2,mwid3))
      self.win_init_done = 1

   def on_window1_focus_in_event(self,wdg,*args):
#      sys.stderr.write("PYTHON: focus in\n")
      self.py2yo('spydr_focus_in')

   def on_window1_focus_out_event(self,wdg,*args):
#      sys.stderr.write("PYTHON: focus out\n")
      self.py2yo('spydr_focus_out')

   def on_drawingarea1_enter_notify_event(self,wdg,*args):
      self.glade.get_widget('eventbox2').grab_focus()
      self.py2yo('start_zoom')
#      if (self.doing_zoom==0):
#         self.py2yo('disp_zoom')
#         self.doing_zoom=1

   def on_drawingarea1_leave_notify_event(self,wdg,event):
      pass
#      sys.stderr.write("%s\n" % event.type)
#      if (event.type==GDK_SCROLL):
#         sys.stderr.write("SCROLL!\n")
#      if (self.doing_zoom==1):
#         self.py2yo('pyk_set stop_zoom 1')
#         self.doing_zoom=0

#   def on_eventbox2_scroll_event(self,wdg,event):
#      sys.stderr.write("SCROLL\n")
#      sys.stderr.write("%s\n" % event)


   def on_spydr_help_activate(self,wdg):
      self.py2yo('spydr_shortcut_help')

   def on_redisp_activate(self,wdg):
      self.py2yo('spydr_redisp')

   def on_rezoom_activate(self,wdg):
      self.py2yo('disp_zoom')

   def on_togglelower_toggled(self,wdg):
      isup=self.glade.get_widget('togglelower').get_active()
      if (isup):
         self.glade.get_widget('frame1').show()
         self.glade.get_widget('frame2').show()
         self.glade.get_widget('table1').show()
         self.glade.get_widget('drawingarea3').show()
      else:
         if (self.spydr_dpi < 70):
            self.glade.get_widget('frame1').hide()
         if (self.spydr_dpi < 85):
            self.glade.get_widget('frame2').hide()
         self.glade.get_widget('table1').hide()
         self.glade.get_widget('drawingarea3').hide()

   def on_propagate_cuts_to_all_activate(self,wdg):
     self.py2yo('propagate_cuts_to_all')

   def on_dpi_change_activate(self,wdg):
#      sys.stderr.write("%s\n" % wdg.get_name())
      if (wdg.get_name()=='dpi_decrease'):
         self.spydr_dpi = self.spydr_dpi * 0.9
      if (wdg.get_name()=='dpi_increase'):
         self.spydr_dpi = self.spydr_dpi * 1.1
      if (wdg.get_name()=='dpi_default'):
         self.spydr_dpi = self.spydr_defaultdpi
      # new size request for drawingareas:
      self.drawingareas_size_allocate(self.spydr_dpi)
      # queue request for parent:
      self.glade.get_widget('drawingarea1').queue_resize()
      # redisplay:
      self.py2yo('spydr_change_dpi %d' % self.spydr_dpi)

   def on_image_menu_selection_done(self,wdg,data):
      # I've tried every signal, and this keeps being called at the
      # deactivate old item and activate new one. So I had to hack it
      # to skip the first (de-activation):
      if (data==self.current_image_menu):
         return
      self.current_image_menu=data
#      w = self.glade.get_widget('image_menu').get_active().get_name()
#      sys.stderr.write("%s\n" % wdg)
#      sys.stderr.write("PYTHON: on_image_menu_selection_done, name= %s, id=%d \n" % (w,data))
#      self.py2yo('set_imnum_by_name \"%s\"' % w.get_name())
      # sync image # entry
      self.glade.get_widget('imnum').set_value(data)
#      self.set_imnum(data)

   def op_multi_im_impossible(self):
      if self.next_to_all:
         self.pyk_status_push(1,'Not implemented or does not make sense on multiple images')
         self.next_to_all = 0


   def on_vbox3_key_press(self,wdg,event):
      # sys.stderr.write("received string: %s\n" % event.string)
      if (event.string==''):
         return True
      if (event.string=='?'):
         self.py2yo('spydr_shortcut_help')
      if (event.string=='k'):
         self.op_multi_im_impossible()
         self.py2yo('disp_fft')
      if (event.string=='B'):
         self.op_multi_im_impossible()
         self.py2yo('mark_current_as_sky')
      if (event.string=='b'):
         self.py2yo('subtract_sky %d' % self.next_to_all)
      if (event.string=='f'):
         self.op_multi_im_impossible()
         self.py2yo('fit_1d 1')
      if (event.string=='F'):
         self.op_multi_im_impossible()
         self.py2yo('fit_1d 0')
      if (event.string=='c'):
         self.op_multi_im_impossible()
         self.py2yo('plot_cut')
      if (event.string=='C'):
         self.py2yo('crop_image %d' % self.next_to_all)
      if (event.string=='u'):
         self.py2yo('unzoom')
         self.py2yo('limits')
      if (event.string=='.'):
         self.op_multi_im_impossible()
         self.py2yo('plot_radial')
      if (event.string=='o'):
         self.py2yo('pyk_set overplot_next 1')
      if (event.string=='r'):
         self.py2yo('rotate_image')
      if (event.string=='X'):
         self.op_multi_im_impossible()
         self.py2yo('toggle_xcut')
      if (event.string=='Y'):
         self.op_multi_im_impossible()
         self.py2yo('toggle_ycut')
      if (event.string=='x'):
         self.op_multi_im_impossible()
         self.py2yo('plot_xcut')
      if (event.string=='y'):
         self.op_multi_im_impossible()
         self.py2yo('plot_ycut')
      if (event.string=='h'):
         self.op_multi_im_impossible()
         self.py2yo('plot_histo')
      if (event.string=='&'):
         self.py2yo('shift_and_add')
      if (event.string=='`'):
         self.py2yo('pick_star_and_add_to_list')
      if (event.string=='~'):
         self.py2yo('pick_star_and_add_to_list_no_fit')
      if (event.string=='!'):
         self.py2yo('reset_star_list')
      if (event.string=='@'):
         self.py2yo('remove_last_from_star_list')
      if (event.string==':'):
         self.py2yo('pick_patch')
      if (event.string==';'):
         self.py2yo('apply_patch')
      if (event.string=='e'):
         self.op_multi_im_impossible()
         self.py2yo('disp_cpc')
         self.py2yo('spydr_disp')
      if (event.string=='E'):
         self.op_multi_im_impossible()
         self.py2yo('disp_cpc 0')
         self.py2yo('spydr_disp')
      if (event.string=='n'):
         self.op_multi_im_impossible()
         n = self.glade.get_widget('imnum').get_value()
         self.glade.get_widget('imnum').set_value(n+1)
      if (event.string=='p'):
         self.op_multi_im_impossible()
         n = self.glade.get_widget('imnum').get_value()
         self.glade.get_widget('imnum').set_value(n-1)
      if (event.string=='R'):
         self.op_multi_im_impossible()
         self.py2yo('spydr_replace_current_from_stack')
      if (event.string=='D'):
         self.op_multi_im_impossible()
         self.py2yo('spydr_delete_current_from_stack')
      if (event.string=='s'):
         self.py2yo('spydr_sigmafilter %d' % self.next_to_all)
      if (event.string=='S'):
         self.py2yo('spydr_smooth_function %d' % self.next_to_all)
      if (event.string=='M'):
         self.op_multi_im_impossible()
         self.py2yo('spydr_compute_distance 1')
      if (event.string=='m'):
         self.op_multi_im_impossible()
         self.py2yo('spydr_compute_distance')
      if (event.string=='z'):
         self.op_multi_im_impossible()
         self.py2yo('plot_zcut')
      if (event.string=='t'):
         self.py2yo('zcut_to_threshold %d' % self.next_to_all)
      if (event.string=='-'):
         self.py2yo('rad4zoom_incr')
      if (event.string=='=') or (event.string=='+'):
         self.py2yo('rad4zoom_decr')
      if (event.string=='*'):
         self.next_to_all = 1
         self.pyk_status_push(1,'Next operation will be applied to all images')
      else:
         self.next_to_all = 0
         self.pyk_status_push(1,'')
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
            if (self.pyk_debug>1):
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
      # carefull with the ident here
      return True

   def set_cursor_busy(self,state):
      if state:
         self.window.window.set_cursor(gtk.gdk.Cursor(gtk.gdk.WATCH))
      else:
         self.window.window.set_cursor(gtk.gdk.Cursor(gtk.gdk.LEFT_PTR))

if len(sys.argv) != 5:
   print 'Usage: spydr.py path_to_spydr spydr_showlower dpi showplugins'
   raise SystemExit

spydrtop = str(sys.argv[1])
spydr_showlower = int(sys.argv[2])
spydr_dpi = int(sys.argv[3])
spydr_showplugins = int(sys.argv[4])
top = spydr(spydrtop,spydr_showlower,spydr_dpi,spydr_showplugins)
