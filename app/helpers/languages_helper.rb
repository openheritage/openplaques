module LanguagesHelper

  def language_path(language, options = {})
    url_for(options.merge(:controller => :languages, :action => :show, :id => language.alpha2))
  end

  def language_if_known(plaque, text = "unknown")
    if plaque.language
	  content_tag("span", plaque.language.name, {:property => "dc:language", :content => plaque.language.alpha2, :datatype => "xsd:language"})
#      link_to(plaque.language.name, language_path(plaque.language), {:property => "dc:language", :content => plaque.language.alpha2, :datatype => "xsd:language"})
    else
      unknown(text)
    end
  end

end
