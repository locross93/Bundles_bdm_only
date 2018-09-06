function luminance_per_pixel=luminance(img_in)
luminance_per_pixel=img_in(:,:,1)*0.2126+img_in(:,:,2)*0.7152+img_in(:,:,3)*0.0722;
end