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
