/*
 * mouse_nowait.c
 *
 * Compiled function which provide functionality for getting
 * the mouse position without blocking
 *
 * This file is part of spydr, an image viewer/data analysis tool
 *
 * $Id: mouse_nowait.c,v 1.2 2007-12-13 13:43:27 frigaut Exp $
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
 * $Log: mouse_nowait.c,v $
 * Revision 1.2  2007-12-13 13:43:27  frigaut
 * - added license headers in all files
 * - added LICENSE
 * - slightly modified Makefile
 * - updated info
 * - bumped to 0.5.1
 *
 *
 *
 */


#include "xbasic.h"
#include "ydata.h"
#include "xfancy.h"
#include "engine.h"
#include <stdio.h>

GpReal xWCS, yWCS;
int sysWCS;

void
Y_mouse_nowait(iarg)
{
  int target_window = ygets_l(--iarg);
//  char *target_window = ygets_q(--iarg);

  if (GhGetPlotter()!=target_window) {
    PushDataBlock(RefNC(&nilDB));
  } else {
    Array *wcs = 0;
    wcs=PushDataBlock(NewArray(&doubleStruct,NewDimension(3L, 1L, (Dimension *)0)));
    wcs->value.d[0]=xWCS;
    wcs->value.d[1]=yWCS;
    wcs->value.d[2]=sysWCS;
  }
}
