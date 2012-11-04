func id_instrument_from_header(fh)
{
  extern user_read_image_fun;
  if (fits_get(fh,"INSTRUME")=="NICI") {
    user_read_image_fun = nici_read;
    return "NICI";
  }
  if ( (fits_get(fh,"INSTRUME")=="GSAOI") &&
       (fits_get(fh,"REDNAME")!="YORICK-REDGSAOI") ) {
    user_read_image_fun = gsaoi_read;
    return "GSAOI";
  }
  user_read_image_fun = [];
  return;
}

func gsaoi_read(imname,&fh,gap_value=)
{
  extern gsaoi_gap;
  gsaoi_gap = 137;
  
  if (gap_value==[]) gap_value=0.0f;
  // read header:
  a = fits_read(imname,fh);

  // read data:
  if (spydr_hdu) return fits_read(imname,hdu=spydr_hdu);
  tmp = fits_read(imname,hdu=2);
  // problem with NaN in the overscan. first column.
  tmp(1,)= tmp(2,);
  dim = dimsof(tmp)(2);
  im = array(float(gap_value),[2,2*dim+gsaoi_gap,2*dim+gsaoi_gap]);
  im(dim+1+gsaoi_gap:,1:dim)    = tmp;

  tmp = fits_read(imname,hdu=3); tmp(1,)= tmp(2,);
  im(1:dim,1:dim)  = tmp;

  tmp = fits_read(imname,hdu=4); tmp(1,)= tmp(2,);
  im(1:dim,dim+1+gsaoi_gap:)    = tmp;

  tmp = fits_read(imname,hdu=5); tmp(1,)= tmp(2,);
  im(dim+1+gsaoi_gap:,dim+1+gsaoi_gap:) = tmp;
  return im;
}

func nici_read(imname)
{
  extern nici_array;
  im = im-im(,::-1);
  grow,nici_array,(fits_get(fh,"CBFW")?"watson":"holmes");
  return im;
}
