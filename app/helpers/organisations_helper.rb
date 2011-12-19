module OrganisationsHelper

  def organisation_path(organisation, options = {})
    url_for(options.merge(:controller => :organisations, :action => :show, :id => organisation.slug))
  end

  def edit_organisation_path(organisation, options = {})
    url_for(options.merge(:controller => :organisations, :action => :edit, :id => organisation.slug))
  end

  def organisation_url(organisation, options = {})
    organisation_path(organisation, options.merge!(:only_path => false))
  end
  
  def most_prevelant_colour(organisation)
    @plaques = organisation.plaques
    most_prevelant_colour = @plaques.map {|i| (i.colour.nil? || i.colour.name) || "" }.group_by {|col| col }.max_by(&:size)
    @colour = most_prevelant_colour ? most_prevelant_colour.first : ""
  end
  
  def org_plaque_icon(organisation)
	  colour = most_prevelant_colour(organisation)
	  if colour =~ /(blue|black|yellow|red|white|green)/
      image_tag("icon-" + colour + ".png", :size => "16x16")
    else
      image_tag("icon-blue.png", :size => "16x16")
    end
  end
end
