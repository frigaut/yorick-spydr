/*
 * mouse_nowait.i
 *
 * Wrapper for mouse_nowait.c, which provide functionality for getting
 * the mouse position without blocking
 *
 * This file is part of spydr, an image viewer/data analysis tool
 *
 * $Id: mouse_nowait.i,v 1.3 2007-12-26 20:32:37 frigaut Exp $
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
 * $Log: mouse_nowait.i,v $
 * Revision 1.3  2007-12-26 20:32:37  frigaut
 * changed name of plugin to be consistant with earlier Makefile changes
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


plug_in,"spydr";

extern mouse_nowait;
