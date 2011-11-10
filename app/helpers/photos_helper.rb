module PhotosHelper

  def photo_img(plaque)
    desc = ""
    if plaque.photos.size > 0
      photo = plaque.photos.first
      desc += "<img src=\""+photo.url+"\"/>"
    end
    return desc.html_safe
  end

  def thumbnail_img(photo_or_plaque)
	desc = ""
	begin
	  if photo_or_plaque.thumbnail_url
        desc += "<img src=\""+photo_or_plaque.thumbnail_url+"\"/>"
	  else
        desc += "<img src=\""+photo_or_plaque.file_url+"\" width=\"75\" height=\"75\"/>"
	  end
	rescue
	  begin
	    # not a photo, maybe it's a plaque
	    if photo_or_plaque.photos.size > 0
          photo = photo_or_plaque.photos.first
          desc += thumbnail_img(photo)
        end
	  rescue
	    ## it wasn't even a plaque  
	  end
	end
    return desc.html_safe
  end

end
