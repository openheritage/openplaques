module PhotosHelper

  def photo_img(plaque)
    desc = ""
    if plaque.photos.size > 0
      photo = plaque.photos.first
      desc += "<img src=\""+photo.url+"\"/>"
    end
    return desc.html_safe
  end

  def thumbnail_img(thing)
    desc = ""
    begin
      begin
        if thing.thumbnail_url
          desc += "<img src=\""+thing.thumbnail_url+"\" width=\"75\" height=\"75\"/>"
        else
          desc += "<img src=\""+thing.file_url+"\" width=\"75\" height=\"75\"/>"
        end
      rescue
        begin
          # not a photo, is it a plaque?
          desc += thumbnail_img(thing.main_photo)
        rescue
          ## it wasn't even a plaque, is it something that links to a plaque?
          desc += thumbnail_img(thing.plaque)
        end
      end
    rescue
      ## oh, I give up!....
      desc += image_tag("NoPhotoSqr.png", :size => "75x75")
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
