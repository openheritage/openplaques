module PhotosHelper

  def photo_img(plaque)
    desc = ""
    if plaque.photos.size > 0
      photo = plaque.photos.first
      desc += "<img src=\""+photo.url+"\"/>"
    end
    return desc.html_safe
  end

  def plaque_thumbnail_img(plaque)
    desc = ""
    if plaque.photos.size > 0
      photo = plaque.photos.first
      desc += "<img src=\""+photo.thumbnail_url+"\"/>"
    end
    return desc.html_safe
  end

  def thumbnail_img(photo)
    desc = ""
	if photo.thumbnail_url
      desc += "<img src=\""+photo.thumbnail_url+"\"/>"
	else
      desc += "<img src=\""+photo.file_url+"\" width=\"75\" height=\"75\"/>"
	end
    return desc.html_safe
  end

end
