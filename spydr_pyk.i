/* spydr_pyk.i
 * 2 way communication interface to python (useful for GUIs)
 * package copy of pyk.i to avoid name collision with other pyk calls.
 *
 * Copyright (c) 2007-2013, Francois Rigaut
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
   Inspired from tyk.i (tcltk interface)
*/

Y_PYTHON = get_env("Y_PYTHON");
if (noneof(Y_PYTHON))                                                   \
  Y_PYTHON="./:"+Y_USER+":"+pathform(_(Y_USER,Y_SITES,Y_SITE)+"python/");


func spydr_pyk(py_command)
/* DOCUMENT spydr_pyk, py_command
 *       or value = spydr_pyk(py_command)
 *
 *   send PY_COMMAND to python front-end.  If the wish front-end is not
 *   already running, spydr_pyk starts it.
 *
 * SEE ALSO: pyk_debug
 */
{
  require,"pathfun.i";

  if (is_void(_spydr_pyk_proc)) {
    error,"_spydr_pyk_proc should not be emtpy on spydr_pyk call within spydr";
  }

  if (is_void(py_command)) return;

  if (pyk_debug) {
    if (strmatch(py_command,"flush")==0) write,format="to python: %s\n",py_command;
  }

  /* send the command to python */
  if (strpart(py_command,0:0) != "\n") py_command += "\n";
  _spydr_pyk_proc, py_command;

}

local pyk_debug;
/* DOCUMENT pyk_debug = 1
 *       or pyk_debug = []
 *
 *   If pyk_debug is non-nil and non-zero, print message traffic to and
 *   from wish.  This is useful for debugging py-yorick interaction.
 *
 * SEE ALSO: spydr_pyk
 */


_spydr_pyk_linebuf = string(0);

func _spydr_pyk_callback(line)
{
  extern _spydr_pyk_proc;
  if (!line) {
    _spydr_pyk_proc = [];
    if (pyk_debug) write, "from python -> <python terminated>";
    return;
  }
  /* must be prepared for python output to dribble back a fraction of
   * a line at a time, or multiple lines at a time
   * _spydr_pyk_linebuf holds the most recent incomplete line,
   *   assuming the the remainder will arrive in future callbacks
   */
  _spydr_pyk_linebuf += line;
  selist = strword(_spydr_pyk_linebuf, "\n", 256);
  line = strpart(_spydr_pyk_linebuf, selist);
  line = line(where(line));
  n = numberof(line);
  if (n && selist(2*n)==strlen(_spydr_pyk_linebuf)) {
    /* final character of input not \n, store fragment in _spydr_pyk_linebuf */
    _spydr_pyk_linebuf = line(0);
    if (n==1) return;
    line = line(1:-1);
  } else {
    _spydr_pyk_linebuf = string(0);
  }
  strtrim, line;
  line = line(where(strlen(line)));

  if (pyk_debug) write, "from python:", line;

  nofline = numberof(line);

  /* parse and execute yorick command lines */
  for (i=1 ; i<=nofline ; i++) funcdef(line(i));
}

func pyk_set(&v1,_x1,&v2,_x2,&v3,_x3,&v4,_x4,&v5,_x5,&v6,_x6,&v7,_x7,&v8,_x8)
/* DOCUMENT pyk_set var1 val1 var2 val2 ...
 *
 *   This function is designed to be invoked by the python front-end;
 *   it is not useful for yorick programs.
 *
 *   Equivalent to
 *     var1=val1; var2=val2; ...
 *   Handles at most 8 var/val pairs.
 *   As a special case, if given an odd number of arguments, pyk_set
 *   sets the final var to [], e.g.-
 *     pyk_set var1 12.34 var2
 *   is equivalent to
 *     var1=12.34; var2=[];
 *
 * SEE ALSO: pyk
 */
{
  v1 = _x1;
  if (is_void(_x1)) return; else v2 = _x2;
  if (is_void(_x2)) return; else v3 = _x3;
  if (is_void(_x3)) return; else v4 = _x4;
  if (is_void(_x4)) return; else v5 = _x5;
  if (is_void(_x5)) return; else v6 = _x6;
  if (is_void(_x6)) return; else v7 = _x7;
  if (is_void(_x7)) return; else v8 = _x8;
}
