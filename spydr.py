#!/usr/bin/env python
# spydr.py
#
# This file is part of spydr, an image viewer/data analysis tool
#
# Copyright (c) 2007-2013, Francois Rigaut
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
#

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from gi.repository import GdkX11
from gi.repository import Gdk
from gi.repository import GObject
from gi.repository import GLib

import sys
# import GObject
# import pango
import os, fcntl, errno

# os.environ["GDK_BACKEND"] = "x11"
# sys.stderr.write(os.environ["GDK_BACKEND"]+'\n')

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

      self.builder = Gtk.Builder()
      self.builder.add_from_file(os.path.join(self.spydrtop,'spydr.ui'))
      self.window = self.builder.get_object("window1")
      if (self.window):
         self.window.connect("destroy", self.destroy)
      self.builder.connect_signals(self)
      
      menubar = self.builder.get_object('menubar1')
      # menubar.set_hexpand(True)

      menuitem_file = Gtk.MenuItem(label="File")
      menubar.append(menuitem_file)
      submenu_file = Gtk.Menu()
      menuitem_file.set_submenu(submenu_file)
      menuitem_open = Gtk.MenuItem(label="Open")
      submenu_file.append(menuitem_open)
      menuitem_open.connect('activate', self.on_menu_open)
      menuitem_add = Gtk.MenuItem(label="Add")
      submenu_file.append(menuitem_add)
      # menuitem_add.connect('activate', self.on_menu_add)
      menuitem_save = Gtk.MenuItem(label="Save")
      submenu_file.append(menuitem_save)
      # menuitem_save.connect('activate', self.on_menu_save)
      menuitem_saveas = Gtk.MenuItem(label="Save as")
      submenu_file.append(menuitem_saveas)
      # menuitem_saveas.connect('activate', self.on_menu_saveas)
      menuitem_exportas = Gtk.MenuItem(label="Export as...")
      submenu_file.append(menuitem_exportas)
      # menuitem_exportas.connect('activate', self.on_menu_exportas)
      menuitem_quit = Gtk.MenuItem(label="Quit")
      submenu_file.append(menuitem_quit)
      menuitem_quit.connect('activate', self.on_menu_quit)

      menuitem_view = Gtk.MenuItem(label="View")
      menubar.append(menuitem_view)
      submenu_view = Gtk.Menu()
      menuitem_view.set_submenu(submenu_view)

      menuitem_refresh = Gtk.MenuItem(label="Refresh Display")
      submenu_view.append(menuitem_refresh)
      # menuitem_refresh.connect('activate', self.on_menu_s)

      menuitem_cutstoplanes = Gtk.MenuItem(label="Current cuts to all planes")
      submenu_view.append(menuitem_cutstoplanes)
      menuitem_cutstoplanes.connect('activate', self.on_propagate_cuts_to_all_activate)

      menuitem_setdpi = Gtk.MenuItem(label="Set dpi")
      submenu_view.append(menuitem_setdpi)
      menuitem_setdpi.connect('activate', self.on_dpi_change_activate)

      menuitem_pluginpane = Gtk.CheckMenuItem(label="Plugin Pane")
      menuitem_pluginpane.set_active(True)
      submenu_view.append(menuitem_pluginpane)
      menuitem_pluginpane.connect('activate', self.on_plugins_toggled)

      togglelower = Gtk.CheckMenuItem(label="Lower Pane")
      togglelower.set_active(True)
      submenu_view.append(togglelower)
      togglelower.connect('activate', self.on_togglelower_toggled)

      menuitem_options = Gtk.MenuItem(label="options")
      menubar.append(menuitem_options)
      submenu_options = Gtk.Menu()
      menuitem_options.set_submenu(submenu_options)
      menuitem_zoomcuts = Gtk.MenuItem(label="Zoom cuts as main image")
      submenu_options.append(menuitem_zoomcuts)
      # menuitem_zoomcuts.connect('activate', self.on_menu_zoomcuts)
      menuitem_inarcsec = Gtk.MenuItem(label="Graph axis in arcsec")
      submenu_options.append(menuitem_inarcsec)
      # menuitem_inarcsec.connect('activate', self.on_menu_inarcsec)
      menuitem_pykdebug = Gtk.MenuItem(label="pyk debug")
      submenu_options.append(menuitem_pykdebug)
      # menuitem_pykdebug.connect('activate', self.on_menu_pykdebug)

      menuitem_images = Gtk.MenuItem(label="images")
      menubar.append(menuitem_images)
      submenu_images = Gtk.Menu()
      menuitem_images.set_submenu(submenu_images)
      menuitem_open = Gtk.MenuItem(label="Open")
      submenu_images.append(menuitem_open)

      menuitem_ops = Gtk.MenuItem(label="ops")
      menubar.append(menuitem_ops)
      submenu_ops = Gtk.Menu()
      menuitem_ops.set_submenu(submenu_ops)
      menuitem_cubemed = Gtk.MenuItem(label="Cube median")
      submenu_ops.append(menuitem_cubemed)
      # menuitem_cubemed.connect('activate', self.on_menu_cubemed)
      menuitem_cubeavg = Gtk.MenuItem(label="Cube average")
      submenu_ops.append(menuitem_cubeavg)
      # menuitem_cubeavg.connect('activate', self.on_menu_cubeavg)
      menuitem_cubesum = Gtk.MenuItem(label="Cube sum")
      submenu_ops.append(menuitem_cubesum)
      # menuitem_cubesum.connect('activate', self.on_menu_cubesum)
      menuitem_cuberms = Gtk.MenuItem(label="Cube rms")
      submenu_ops.append(menuitem_cuberms)
      # menuitem_cuberms.connect('activate', self.on_menu_cuberms)
      menuitem_cubemin = Gtk.MenuItem(label="Cube min")
      submenu_ops.append(menuitem_cubemin)
      # menuitem_cubemin.connect('activate', self.on_menu_cubemin)
      menuitem_cubemax = Gtk.MenuItem(label="Cube max")
      submenu_ops.append(menuitem_cubemax)
      # menuitem_cubemax.connect('activate', self.on_menu_cubemax)

      menuitem_help = Gtk.MenuItem(label="help")
      menubar.append(menuitem_help)
      submenu_help = Gtk.Menu()
      menuitem_help.set_submenu(submenu_help)
      menuitem_restartzoom = Gtk.MenuItem(label="Restart Zoom")
      submenu_help.append(menuitem_restartzoom)
      # menuitem_restartzoom.connect('activate', self.on_menu_restartzoom)
      menuitem_Help = Gtk.MenuItem(label="Help")
      submenu_help.append(menuitem_Help)
      # menuitem_Help.connect('activate', self.on_menu_Help)
      menuitem_about = Gtk.MenuItem(label="About")
      submenu_help.append(menuitem_about)
      menuitem_about.connect('activate', self.on_about_activate)

      # self.window.connect('key-press-event', self.on_key_function)

      # menuitem_quit = Gtk.MenuItem(label="Quit")
      # submenu_file.append(menuitem_quit)
      # menuitem_quit.connect('activate', self.on_menu_quit)

      # menuitem_edit = Gtk.MenuItem(label="Edit")
      # menubar.append(menuitem_edit)

      # self.builder = gtk.glade.XML(os.path.join(self.spydrtop,'spydr.glade'))
      # self.window = self.builder.get_object('window1')
      # handle destroy event
      # if (self.window):
      #    self.window.connect('destroy', self.destroy)
      # self.builder.signal_autoconnect(self)

      # set stdin non blocking, this will prevent readline to block
      fd = sys.stdin.fileno()
      flags = fcntl.fcntl(fd, fcntl.F_GETFL)
      fcntl.fcntl(fd, fcntl.F_SETFL, flags | os.O_NONBLOCK)

      # add stdin to the event loop (yorick input pipe by spawn)
      GLib.io_add_watch(sys.stdin,GLib.IO_IN|GLib.IO_HUP,self.yo2py,None)

      # update parameters from yorick:
      self.py2yo('gui_update')

      ebox = self.builder.get_object('vbox3')
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

      self.window.show_all()

      if (spydr_showlower==0):
         sys.stderr.write("showlower=0\n")
         if (spydr_dpi < 70):
            self.builder.get_object('frame1').hide()
         if (spydr_dpi < 85):
            self.builder.get_object('frame2').hide()
         self.builder.get_object('table1').hide()
         self.builder.get_object('drawingarea3').hide()
         # self.builder.get_object('togglelower').set_active(0)

      if (spydr_showplugins==0):
         self.builder.get_object('plugins_pane').hide()

      self.pyk_status_push(1,'Initializing...')

      # run
      Gtk.main()

   doing_zoom=0
   done_init=0

   # def on_key_function(self,wdg,event):
   #    # keyname = Gdk.keyval_name(event.keyval) 
   #    # if (Gdk.GDK_CONTROL_MASK & keyname == 'q'):
   #    sys.stderr.write('hello')
   #    if ((event.keyval == 'q') and (event.state & Gdk.ModifierType.CONTROL_MASK)):
   #       self.window.destroy()

   def on_menu_open(self,wdg):
      print("add file open dialog")
   
   def on_menu_quit(self,wdg):
      self.window.destroy()

   def on_about_activate(self,wdg):
      dialog = self.builder.get_object('aboutdialog')
      dialog.run()
      dialog.hide()

   def on_window1_size_request(self,wdg,*arg):
      #  sys.stderr.write("PYTHON: window1 size = %d x %d\n" % wdg.get_size())
#      sys.stderr.write("PYTHON: vbox2 height = %s\n" % self.builder.get_object('vbox2').get_allocation().height)
#      sys.stderr.write("PYTHON: zoom height = %s\n" % self.builder.get_object('zoom').get_allocation().height)
#      sys.stderr.write("PYTHON: actions height = %s\n" % self.builder.get_object('frame1').get_allocation().height)
#      sys.stderr.write("PYTHON: LUT height = %s\n" % self.builder.get_object('frame2').get_allocation().height)
#      sys.stderr.write("PYTHON: table1 height = %s\n\n" % self.builder.get_object('table1').get_allocation().height)

#      avail = self.builder.get_object('vbox2').get_allocation().height
      tb = self.builder.get_object('menubar1').get_allocation().height
      tb = tb+self.builder.get_object('statusbar').get_allocation().height+10
#      sys.stderr.write("PYTHON: menuabar1+statusbar = %d\n\n" % tb)
      avail = wdg.get_size()[1]-tb
      h = self.builder.get_object('zoom').get_allocation().height
      h = h + self.builder.get_object('frame1').get_allocation().height
      if (h<avail):
         self.builder.get_object('frame1').show()
      else:
         self.builder.get_object('frame1').hide()
      h = h + self.builder.get_object('frame2').get_allocation().height
      if (h<(avail)):
         self.builder.get_object('frame2').show()
      else:
         self.builder.get_object('frame2').hide()
      h = h + self.builder.get_object('table1').get_allocation().height
      if (h<(avail)):
         self.builder.get_object('table1').show()
      else:
         self.builder.get_object('table1').hide()

#      sys.stderr.write("PYTHON: available = %d, sum = %d\n\n" % (avail,h))

   def drawingareas_size_allocate(self,dpi):
#      sys.stderr.write("PYTHON: new dpi = %d \n" % dpi)
      dsx = int(595.*dpi/100)+4
      dsy = int(596.*dpi/100)+25
      self.builder.get_object('drawingarea1').set_size_request(dsx,dsy)
      dsx = int(595.*dpi/100)+4
      dsy = int(307.*dpi/100)+25
      self.builder.get_object('drawingarea3').set_size_request(dsx,dsy)

   #
   # Yorick to Python Wrapper Functions
   #

   def y_parm_update(self,name,val):
      self.builder.get_object(name).set_value(val)

   def y_text_parm_update(self,name,txt):
      self.builder.get_object(name).set_text(txt)

   def y_set_checkbutton(self,name,val):
      self.builder.get_object(name).set_active(val)

   def y_set_xyz(self,x,y,z):
      self.builder.get_object('xvalue').set_text(x)
      self.builder.get_object('yvalue').set_text(y)
      self.builder.get_object('zvalue').set_text(z)

   def y_set_user_function1_name(self,txt):
      self.builder.get_object('user_function1').set_label(txt)

   def y_set_user_function2_name(self,txt):
      self.builder.get_object('user_function2').set_label(txt)

   def pyk_status_push(self,id,txt):
      self.builder.get_object('statusbar').push(id,txt)

   def pyk_status_pop(self,id):
      self.builder.get_object('statusbar').pop(id)

   def y_set_lut(self,value):
#      if (self.done_init):
      self.builder.get_object('colors').set_value(value)

   def y_set_invertlut(self,value):
#      if (self.done_init):
      self.builder.get_object('invert').set_active(value)

   def y_set_itt(self,value):
      pass
#      if (self.done_init):
      ### self.builder.get_object('itt').set_active(value)

   def y_set_cmincmax(self,cmin,cmax,incr,only_values):
      if (only_values!=1):
         pass
#         self.builder.get_object('cmin').set_range(cmin,cmax)
#         self.builder.get_object('cmax').set_range(cmin,cmax)
      self.builder.get_object('cmin').set_increments(incr,incr)
      self.builder.get_object('cmax').set_increments(incr,incr)
      self.builder.get_object('cmin').set_value(cmin)
      self.builder.get_object('cmax').set_value(cmax)

   def reset_image_menu(self):
      return
      c = self.builder.get_object('image_menu').get_children()
      for item in c:
         #sys.stderr.write("PYTHON: removing menu item =%s \n" % item.get_name())
         self.builder.get_object('image_menu').remove(item)

   def add_to_image_menu(self,name,ind):
      return
      item=gtk.MenuItem(label=name)
      item.set_name(name)
      item.connect("activate",self.on_image_menu_selection_done, ind)
      self.builder.get_object('image_menu').append(item)
      item.show()


   def pyk_error(self,msg):
      dialog = Gtk.MessageDialog(message_type=Gtk.MessageType.ERROR,buttons=Gtk.ButtonsType.OK,message_format=msg)
      dialog.run()
      dialog.destroy()

   def pyk_info(self,msg):
      dialog = Gtk.MessageDialog(message_type=Gtk.MessageType.INFO,buttons=Gtk.ButtonsType.OK,message_format=msg)
      dialog.run()
      dialog.destroy()

   def pyk_info_w_markup(self,msg):
      dialog = Gtk.MessageDialog(message_type=Gtk.MessageType.INFO,buttons=Gtk.ButtonsType.OK)
      dialog.set_markup(msg)
#      dialog.set_size_request(600,-1)
      dialog.run()
      dialog.destroy()

   def pyk_warning(self,msg):
      dialog = Gtk.MessageDialog(message_type=Gtk.MessageType.WARNING,buttons=Gtk.ButtonsType.OK,message_format=msg)
      dialog.run()
      dialog.destroy()

   def on_debug_toggled(self,wdg):
      if (wdg.active()):
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
      self.py2yo('spydr_set_plot_in_arcsec %d' % self.builder.get_object('plot_in_arcsec').active())

   def on_ccolor_toggled(self,wdg):
      data = self.builder.get_object('ccolor').get_active()
      #sys.stderr.write("PYTHON: color = %s \n" % data.get_name())
      self.py2yo('set_spydr_ccolor \"%s\"' % data.get_name())

   def on_mcolor_toggled(self,wdg):
      data = self.builder.get_object('mcolor').get_active()
      self.py2yo('set_spydr_mcolor \"%s\"' % data.get_name()[1:])

   def on_clabel_toggled(self,wdg):
      data = self.builder.get_object('clabel').get_active()
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
         self.py2yo('pyk_set spydr_invertlut %d' % wdg.active())
         self.py2yo('spydr_set_lut')


   def on_plugins_toggled(self,wdg):
      show_state = wdg.get_active()
      if (show_state):
         try:
            s = self.window.get_size()
         except:
            s = 0
         self.size = self.window.get_size()
         self.builder.get_object('plugins_pane').show()
         self.builder.get_object('plugins_pane').set_sensitive(1)
         if (s):
            self.window.resize(s[0],s[1])
      else:
         s = self.window.get_size()
         self.builder.get_object('plugins_pane').hide()
         self.window.resize(s[0],s[1])
      self.py2yo('pyk_set spydr_showplugins %d' % show_state)

   def toggleplugins(self):
      isvis = self.builder.get_object('plugins_pane').is_visible()
      if (isvis):
         s = self.window.get_size()
         self.builder.get_object('plugins_pane').hide()
         self.window.resize(s[0],s[1])
      else:
         try:
            s = self.window.get_size()
         except:
            s = 0
         self.size = self.window.get_size()
         self.builder.get_object('plugins_pane').show()
         self.builder.get_object('plugins_pane').set_sensitive(1)
         if (s):
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
      find_fwhm = self.builder.get_object('find_fwhm').get_value()
      find_threshold = self.builder.get_object('find_threshold').get_value()
      find_roundlim = self.builder.get_object('find_roundlim').get_value()
      find_sharplow = self.builder.get_object('find_sharplow').get_value()
      find_sharphigh = self.builder.get_object('find_sharphigh').get_value()
      self.py2yo('spydr_find %f %f %f %f %f' % \
             (find_fwhm,find_threshold,find_roundlim,find_sharplow,find_sharphigh))

   def on_strehl_map_clicked(self,wdg):
      self.py2yo('spydr_strehl_map')

   def on_quit_activate(self,*args):
      self.py2yo('spydr_quit')
      raise SystemExit()

   def on_azimuth_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_azimuth %f' % self.builder.get_object('azimuth').get_value())
         self.py2yo('spydr_disp')

   def on_elevation_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_elevation %f' % self.builder.get_object('elevation').get_value())
         self.py2yo('spydr_disp')

   def on_binsize_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_histbinsize %f' % self.builder.get_object('binsize').get_value())
         #isup=self.builder.get_object('togglelower').get_active()
         #if (isup):
         #   self.py2yo('plot_histo')

   def on_pixsize_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('spydr_set_pixsize %f' % self.builder.get_object('pixsize').get_value())

   def on_boxsize_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_boxsize %d' % self.builder.get_object('boxsize').get_value())

   def on_saturation_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_saturation %f' % self.builder.get_object('saturation').get_value())

   def on_airmass_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_airmass %f' % self.builder.get_object('airmass').get_value())

   def on_wavelength_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('spydr_set_wavelength %f' % self.builder.get_object('wavelength').get_value())

   def on_zero_point_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_zero_point %f' % self.builder.get_object('zero_point').get_value())

   def on_teldiam_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_teldiam %f' % self.builder.get_object('teldiam').get_value())

   def on_cobs_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_cobs %f' % self.builder.get_object('cobs').get_value())

   def on_strehl_aper_diameter_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_strehlaper %f' % self.builder.get_object('strehl_aper_diameter').get_value())

   def on_compute_strehl_toggled(self,wdg):
      self.py2yo('pyk_set compute_strehl %d' % wdg.get_active())
      self.builder.get_object('wavelength_label').set_sensitive(wdg.get_active())
      self.builder.get_object('wavelength').set_sensitive(wdg.get_active())
      self.builder.get_object('teldiam_label').set_sensitive(wdg.get_active())
      self.builder.get_object('teldiam').set_sensitive(wdg.get_active())
      self.builder.get_object('cobs_label').set_sensitive(wdg.get_active())
      self.builder.get_object('cobs').set_sensitive(wdg.get_active())
      self.builder.get_object('strehl_aper_diameter_label').set_sensitive(wdg.get_active())
      self.builder.get_object('strehl_aper_diameter').set_sensitive(wdg.get_active())

   def on_output_magnitudes_toggled(self,wdg):
      self.builder.get_object('zero_point_label').set_sensitive(wdg.get_active())
      self.builder.get_object('zero_point').set_sensitive(wdg.get_active())

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
         self.py2yo('set_cmin %f' % self.builder.get_object('cmin').get_value())

   def on_cmax_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('set_cmax %f' % self.builder.get_object('cmax').get_value())

   def on_colors_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('spydr_set_lut %d' % self.builder.get_object('colors').get_value())
         self.builder.get_object('invert').set_active(0)

   def on_tv_pressed(self,wdg):
      self.builder.get_object('contours_plus_tv').set_sensitive(0)
      self.builder.get_object('contours_filled').set_sensitive(0)
      self.builder.get_object('shades').set_sensitive(0)
      self.builder.get_object('azimuth_label').hide()
      self.builder.get_object('azimuth').hide()
      self.builder.get_object('elevation_label').hide()
      self.builder.get_object('elevation').hide()
      self.builder.get_object('nlevs_label').hide()
      self.builder.get_object('nlevs').hide()
      if (self.done_init):
         #self.builder.get_object('contours_plus_tv').set_active(0)
         #self.builder.get_object('contours_filled').set_active(0)
         self.py2yo('switch_disp 1') # 1 is tv

   def on_contours_pressed(self,wdg):
      self.builder.get_object('contours_plus_tv').set_sensitive(1)
      self.builder.get_object('contours_filled').set_sensitive(1)
      self.builder.get_object('shades').set_sensitive(0)
      self.builder.get_object('azimuth_label').hide()
      self.builder.get_object('azimuth').hide()
      self.builder.get_object('elevation_label').hide()
      self.builder.get_object('elevation').hide()
      self.builder.get_object('nlevs_label').show()
      self.builder.get_object('nlevs').show()
      self.py2yo('pyk_set spydr_filled %d' % self.builder.get_object('contours_filled').get_active())
      if (self.done_init):
         if (self.builder.get_object('contours_plus_tv').get_active()):
            self.py2yo('switch_disp 4') # 4 is contour+tv
         else:
            self.py2yo('switch_disp 2') # 2 is contour

   def on_surface_pressed(self,wdg):
      self.builder.get_object('contours_plus_tv').set_sensitive(0)
      self.builder.get_object('contours_filled').set_sensitive(0)
      self.builder.get_object('shades').set_sensitive(1)
      #self.builder.get_object('contours_plus_tv').set_active(0)
      #self.builder.get_object('contours_filled').set_active(0)
      self.builder.get_object('azimuth_label').show()
      self.builder.get_object('azimuth').show()
      self.builder.get_object('elevation_label').show()
      self.builder.get_object('elevation').show()
      self.builder.get_object('nlevs_label').hide()
      self.builder.get_object('nlevs').hide()
      if (self.done_init):
         self.py2yo('switch_disp 3') # 3 is surface

   def on_contours_filled_toggled(self,wdg):
      if (self.done_init):
         if (wdg.get_active()):
            if (self.builder.get_object('contours_plus_tv').get_active()):
               self.builder.get_object('contours_plus_tv').set_active(0)
         self.py2yo('pyk_set spydr_filled %d' % wdg.get_active())
         self.py2yo('spydr_disp')

   def on_contours_plus_tv_toggled(self,wdg):
      if (self.done_init):
         if (wdg.get_active()):
            if (self.builder.get_object('contours_filled').get_active()):
               self.builder.get_object('contours_filled').set_active(0)
            self.py2yo('switch_disp 4') # 4 is contour+tv
         else:
            self.py2yo('switch_disp 2') # 2 is contour

   def on_shades_toggled(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_shades %d' % wdg.get_active())
         self.py2yo('spydr_disp')

   def on_rebin_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('spydr_rebin %d' % self.builder.get_object('rebin').get_value())
         self.py2yo('spydr_disp')


   def on_nlevs_value_changed(self,wdg):
      if (self.done_init):
         self.py2yo('pyk_set spydr_nlevs %d' % self.builder.get_object('nlevs').get_value())
         self.py2yo('spydr_disp')

   def on_imnum_value_changed(self,wdg):
      #if (self.just_done_range):
      #   self.just_done_range=0
      #   return
      if (self.done_init):
         imnum = self.builder.get_object('imnum').get_value()
         #sys.stderr.write("PYTHON: on_imnum_value_changed, imnum=%d \n" % imnum)
         # set yorick image #
         self.py2yo('set_imnum %d 1' % imnum)
         self.py2yo('imchange_update')
         self.builder.get_object('rebin').set_value(0)

   def set_imnum(self,imnum,numim,vis):
      #sys.stderr.write("PYTHON: entering set_imnum with request %d\n" % imnum)
      if (self.done_init):
         if (vis):
            self.builder.get_object('imnum').set_range(1,numim)
            #self.just_done_range=1
            self.builder.get_object('imnum_label').set_text("image#(%d)" % numim)
            self.builder.get_object('imnum_label').show()
            self.builder.get_object('imnum').show()
         else:
            self.builder.get_object('imnum_label').hide()
            self.builder.get_object('imnum').hide()
         # update imnum widget value if needed
         current1 = self.builder.get_object('imnum').get_value()
         #sys.stderr.write("PYTHON: current image=%d\n" % current1)
         if (current1!=imnum):
            self.builder.get_object('imnum').set_value(imnum)

   def on_window1_map_event(self,wdg,*args):
      sys.stderr.write("entering window map event")
      if (self.win_init_done): return
      drawingarea = self.builder.get_object('drawingarea1')
      # mwid1 = drawingarea.window.xid;
      mwid1 = drawingarea.get_property('window').get_xid()
      drawingarea = self.builder.get_object('drawingarea2')
      # mwid2 = drawingarea.window.xid
      mwid2 = drawingarea.get_property('window').get_xid()
      drawingarea = self.builder.get_object('drawingarea3')
      # mwid3 = drawingarea.window.xid
      mwid3 = drawingarea.get_property('window').get_xid()
      # set size of drawingarea2, just once per session:
      dsx = int(183.*self.spydr_dpi/100)+4
      dsy = int(183.*self.spydr_dpi/100)+25
      self.builder.get_object('drawingarea2').set_size_request(dsx,dsy)

      self.py2yo('spydr_win_init %d %d %d' % (mwid1,mwid2,mwid3))
      self.win_init_done = 1

   def on_window1_focus_in_event(self,wdg,*args):
#      sys.stderr.write("PYTHON: focus in\n")
      self.py2yo('spydr_focus_in')

   def on_window1_focus_out_event(self,wdg,*args):
#      sys.stderr.write("PYTHON: focus out\n")
      self.py2yo('spydr_focus_out')

   def on_drawingarea1_enter_notify_event(self,wdg,*args):
      self.builder.get_object('eventbox2').grab_focus()
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
      isup=wdg.get_active()
      if (isup):
         self.builder.get_object('frame1').show()
         self.builder.get_object('frame2').show()
         self.builder.get_object('table1').show()
         self.builder.get_object('drawingarea3').show()
      else:
         if (self.spydr_dpi < 70):
            self.builder.get_object('frame1').hide()
         if (self.spydr_dpi < 85):
            self.builder.get_object('frame2').hide()
         self.builder.get_object('table1').hide()
         self.builder.get_object('drawingarea3').hide()

   def togglelower(self):
      isvis=self.builder.get_object('drawingarea3').is_visible()
      if (isvis):
         if (self.spydr_dpi < 70):
            self.builder.get_object('frame1').hide()
         if (self.spydr_dpi < 85):
            self.builder.get_object('frame2').hide()
         self.builder.get_object('table1').hide()
         self.builder.get_object('drawingarea3').hide()
      else:
         self.builder.get_object('frame1').show()
         self.builder.get_object('frame2').show()
         self.builder.get_object('table1').show()
         self.builder.get_object('drawingarea3').show()

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
      self.builder.get_object('drawingarea1').queue_resize()
      # redisplay:
      self.py2yo('spydr_change_dpi %d' % self.spydr_dpi)

   def on_image_menu_selection_done(self,wdg,data):
      # I've tried every signal, and this keeps being called at the
      # deactivate old item and activate new one. So I had to hack it
      # to skip the first (de-activation):
      if (data==self.current_image_menu):
         return
      self.current_image_menu=data
#      w = self.builder.get_object('image_menu').get_active().get_name()
#      sys.stderr.write("%s\n" % wdg)
#      sys.stderr.write("PYTHON: on_image_menu_selection_done, name= %s, id=%d \n" % (w,data))
#      self.py2yo('set_imnum_by_name \"%s\"' % w.get_name())
      # sync image # entry
      self.builder.get_object('imnum').set_value(data)
#      self.set_imnum(data)

   def op_multi_im_impossible(self):
      if self.next_to_all:
         self.pyk_status_push(1,'Not implemented or does not make sense on multiple images')
         self.next_to_all = 0


   def on_vbox3_key_press(self,wdg,event):

      keyname = Gdk.keyval_name(event.keyval)
      ctrl = event.state & Gdk.ModifierType.CONTROL_MASK
      # sys.stderr.write("received string: %s, keyname: %s\n" % (event.string,keyname))

      if ctrl:
         if keyname=='q':
            self.window.destroy()
         elif keyname=='l':
            self.togglelower()
         elif keyname=='p':
            self.toggleplugins()
         if event.string=='-':
            self.spydr_dpi = self.spydr_dpi * 0.9
            self.drawingareas_size_allocate(self.spydr_dpi)
            self.builder.get_object('drawingarea1').queue_resize()
            self.py2yo('spydr_change_dpi %d' % self.spydr_dpi)
         if event.string=='=':
            self.spydr_dpi = self.spydr_dpi * 1.1
            self.drawingareas_size_allocate(self.spydr_dpi)
            self.builder.get_object('drawingarea1').queue_resize()
            self.py2yo('spydr_change_dpi %d' % self.spydr_dpi)


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
         n = self.builder.get_object('imnum').get_value()
         self.builder.get_object('imnum').set_value(n+1)
      if (event.string=='p'):
         self.op_multi_im_impossible()
         n = self.builder.get_object('imnum').get_value()
         self.builder.get_object('imnum').set_value(n-1)
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
      if (event.string=='Z'):
         self.op_multi_im_impossible()
         self.py2yo('plot_zcutmax')
      if (event.string=='t'):
         self.py2yo('zcut_to_threshold %d' % self.next_to_all)
      if (event.string=='-'):
         self.py2yo('rad4zoom_incr')
      if (event.string=='='):
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
      if cb_condition == GLib.IO_HUP:
         raise SystemExit('lost pipe to yorick')
      # handles string command from yorick
      # note: inidividual message needs to end with /n for proper ungarbling
      while 1:
         try:
            msg = sys.stdin.readline()
            if msg == "":
               return True
            msg = "self."+msg
            if (self.pyk_debug>1):
               sys.stderr.write("Python stdin:"+msg)
            exec(msg)
         except IOError as e:
            if e.errno == errno.EAGAIN:
               # the pipe's empty, good
               break
            # else bomb out
            raise SystemExit('yo2py unexpected IOError:' + str(e))
         # except Exception as ee:
         #    raise SystemExit('yo2py unexpected Exception:' + str(ee))
      # carefull with the ident here
      return True

   def set_cursor_busy(self,state):
      return
      if state:
         # self.window.window.set_cursor(gtk.gdk.Cursor(gtk.gdk.WATCH))
         # Gdk.Cursor.new_from_name(self.window,"progress")
         watch = Gdk.Cursor(Gdk.CursorType.WATCH)
         gdk_window = self.window.get_root_window()
         gdk_window.set_cursor(watch)
      else:
         # self.window.window.set_cursor(gtk.gdk.Cursor(gtk.gdk.LEFT_PTR))
         # Gdk.Cursor.new_from_name(self.window,"pointer")
         watch = Gdk.Cursor(Gdk.CursorType.LEFT_PTR)
         gdk_window = self.window.get_root_window()
         gdk_window.set_cursor(watch)

if len(sys.argv) != 5:
   print('Usage: spydr.py path_to_spydr spydr_showlower dpi showplugins')
   raise SystemExit()

spydrtop = str(sys.argv[1])
spydr_showlower = int(sys.argv[2])
spydr_dpi = int(sys.argv[3])
spydr_showplugins = int(sys.argv[4])
top = spydr(spydrtop,spydr_showlower,spydr_dpi,spydr_showplugins)
