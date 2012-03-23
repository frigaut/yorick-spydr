func id_instrument_from_header(fh)
{
  extern user_read_image_fun;
  if (fits_get(fh,"INSTRUME")=="NICI") {
    user_read_image_fun = nici_read;
    return "NICI";
  }
  if (fits_get(fh,"INSTRUME")=="GSAOI") {
    user_read_image_fun = gsaoi_read;
    return "GSAOI";
  }
  if (fits_get(fh,"INSTRUME")=="GMOS-S") {
    user_read_image_fun = gmoss_read;
    return "GMOS-S";
  }
  user_read_image_fun = [];
  return;
}

func gmoss_read(imname)
{
  extern spydr_pixsize;
  spydr_pixsize = 0.0359;
  tmp = fits_read(imname,hdu=2);
  dim = dimsof(tmp);
  if (dim(3)>3000) {
    gap=36; 
    oscan = 32;
  } else {
    gap=18;
    oscan = 16;
  }
  dim(2)-=oscan*2;
  im = array(0.0f,[2,3*dim(2)+2*gap,dim(3)]);
  im(1:dim(2),)  = tmp(1+oscan:-oscan,);
  im(dim(2)+gap+1:2*dim(2)+gap,) = fits_read(imname,hdu=3)(1+oscan:-oscan,);
  im(2*dim(2)+2*gap+1:3*dim(2)+2*gap,) = fits_read(imname,hdu=4)(1+oscan:-oscan,);
  return im;
}

func gsaoi_read(imname)
{
  extern spydr_pixsize;
  spydr_pixsize = 0.02;
  if (spydr_hdu) return fits_read(imname,hdu=spydr_hdu);
  tmp = fits_read(imname,hdu=2);
  dim = dimsof(tmp)(2);
  im = array(0.0f,[2,2*dim+170,2*dim+170]);
  im(dim+1+170:,1:dim)    = tmp;
  im(1:dim,1:dim)       = fits_read(imname,hdu=3);
  im(1:dim,dim+1+170:)    = fits_read(imname,hdu=4);
  im(dim+1+170:,dim+1+170:) = fits_read(imname,hdu=5);
  return im;
}

func nici_read(imname)
{
  extern nici_array;
  im = im-im(,::-1);
  grow,nici_array,(fits_get(fh,"CBFW")?"watson":"holmes");
  return im;
}
