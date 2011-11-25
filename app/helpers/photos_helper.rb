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

  # this works, but slows the page down if you use it a lot probably because it does a read of the photos
  def thumbnail_icon(plaque)
    if plaque.photographed?
	  camera_icon = link_to(thumbnail_img(plaque.main_photo),plaque)
	else
      camera_icon = image_tag("EOS-300D-32x32.png".html_safe, {:alt => "Plaque needs photographing".html_safe})
    end
  end

  def camera_icon(plaque)
    if plaque.photographed?
      camera_icon = image_tag("EOS-300D-32x32.png".html_safe, {:alt => "Plaque has been photographed".html_safe})
    end
  end
end
