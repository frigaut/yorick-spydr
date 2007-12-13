func spydr_find(fwhm,threshold,roundlim,sharplow,sharphigh)
// FIND plugin
{
  require,"multistrehl/find.i";
  
  extern spydr_fit_fwhm_estimate;
  extern spydr_fit_background_estimate;
  extern find_x,find_y,find_flux,find_round,find_sharp;
  
  threshold += spydr_fit_background_estimate;
  if (fwhm==0) fwhm = spydr_fit_fwhm_estimate;
  roundlim = [-1,1]*roundlim;
  sharplim = [sharplow,sharphigh];

  find_x = find_y = find_flux = find_round = find_sharp=[];
  
  find,spydr_im,find_x,find_y,find_flux,find_round,find_sharp,\
    threshold,fwhm,roundlim,sharplim;

  // some filtering:
  nstars = numberof(find_x);
  // filter source too close to the edge of the image:
  w =  (find_x > 10);
  w &= (find_x < (spydr_dims(2)-10));
  w &= (find_y > 10);
  w &= (find_y < (spydr_dims(3)-10));

  n_too_close = sum(1-w);
  write,format="no. of sources rejected by close2edge criteria %d\n",n_too_close;
  
  // filter sources which have a bright neighbor:
  // the sources are sorted by flux out of find()
  dmin = 15; // min distance to neighbor in pixels
  flux_ratio_min = 0.2;  // flux ratio above which we filtered both stars

  for (i=1;i<=nstars;i++) {
    if (w(i)==0) continue; // this guys has already been filtered out.
    
    d = abs(find_x-find_x(i),find_y-find_y(i)); // distance to others
    d(i) = 2*dmin; // to avoid filtering oneself
    wn = where(d<dmin);
    
    if (numberof(wn)==0) continue; // no stars within dmin
    flux_ratio = find_flux(wn)/find_flux(i);  // ratio of neighbor to main
    if (anyof(flux_ratio>flux_ratio_min)) w(i)=0; // filter out oneself.
    // filter the other guys:
    w(wn) = 0;
  }
  
  write,format="no. of sources rejected by neighbor criteria %d\n",
    sum(1-w)-n_too_close;

  spydr_disp;
  // plot all stars (including filtered out)
  plp,find_y-0.5,find_x-0.5,symbol=2,size=0.6,color="blue";
  
  w = where(w);
  
  find_x = find_x(w);
  find_y = find_y(w);
  find_flux = find_flux(w);
  find_round = find_round(w);
  find_sharp = find_sharp(w);
  
  write,format="no of valid stars %d\n",numberof(find_x);

  // plot valid stars:
  plp,find_y-0.5,find_x-0.5,size=0.6,color="red";
}


func spydr_strehl_map(void)
{
  extern find_x,find_y,find_flux,find_round,find_sharp;
  res=yfwhm(spydr_im,0,find_x,find_y,find_flux,funtype=spydr_funtype);

  window,spydr_wins(1);  
  plp,res.ypos,res.xpos,size=0.4,color="green",symbol=2;
  // now we miss:
  // - some filtering for the point we got out of yfwhm
  // - compute the strehls
  // - draw the maps
  // - do multi-psf fitting for the objects that are packed together?
  // - implement manual filtering/picking of bad sources out of the find list.
  // - do a second threshold before sending to yfwhm (idea is to have a low threshold
  //   for first find so that we can filter, and then keep only the SNR large enough.
  // - fix psffit to allow varying range for FWHM in gaussian()
}
