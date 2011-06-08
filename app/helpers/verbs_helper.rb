module VerbsHelper

  def verb_path(verb, options = {})
    url_for(options.merge(:controller => :verbs, :action => :show, :id => verb.name))
  end

  def past_tense(verb)
    if verb =~ /e\Z/
      return verb + "d"
    else
      return verb + "ed"
    end
  end

end
