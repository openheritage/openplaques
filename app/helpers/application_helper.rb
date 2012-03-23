# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def alternate_link_to(text, path, format)
    link_to text, path, :type => Mime::Type.lookup_by_extension(format.to_s).to_s, :rel => [:alternate,:nofollow]
  end


  def fieldset(options = {}, &block)
    content_tag("fieldset", options, &block)
  end

  def csv_escape(string)
    unless string.blank?
      '"' + string.gsub(/[\r\n]/, " ").gsub(/\s\s+/, " ").strip + '"'
    else
      ""
    end
  end

  def block_tag(tag, options = {}, &block)
    concat(content_tag(tag, capture(&block), options), block.binding)
  end

  def google_analytics_code(code)

    var = "var _gaq = _gaq || [];
    _gaq.push(['_setAccount', '#{code}']);
    _gaq.push(['_setDomainName', '.openplaques.org']);
    _gaq.push(['_trackPageview']);
    "
    var += "_gaq.push(['_setVar', 'admin']);\n" if current_user.try(:is_admin?)

    function = "(function() {
      var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
      ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
    })();"

    return javascript_tag(var + function)
  end

  # h() replaces some characters, but not apostrophes or carriage returns
  def html_safe(phrase)
    return h(phrase).gsub(/'/,'&#39;').gsub(/\r\n/,"<br/>")
  end

  def unknown(text = "unknown")
    content_tag("span", text, :class => :unknown)
  end

  def user_menu
    if user_signed_in?
      content_tag("p", ("You are logged in as ".html_safe +
        current_user.email +
#        link_to(current_user.email, edit_user_registration_path) +
        ". " +
        link_to("Logout", destroy_user_session_path)
      ), {:class => "user_info"})
    else
      content_tag("p", link_to("Login", new_user_session_path), {:class => "user_info"})
    end
  end

  # Outputs an abbreviation tag for 'circa'.
  #
  # ==== Example output:
  #   <abbr title="circa">c</abbr>
  def circa_tag
    return content_tag("abbr", "c", {:title => "circa"})
  end

  # Produces a link wrapped in a list item element (<li>).
  def list_link_to(link_text, options = {}, html_options = {})
    content_tag("li", link_to(link_text, options, html_options))
  end

  def linked_personal_connections(personal_connections)
    locations = []
    personal_connections.each do |personal_connection|
      locations << personal_connection.location
    end
    locations.uniq!
    ret = "".html_safe
    locations.each do |location|
      verbs = []
      personal_connections.each do |personal_connection|
        if personal_connection.location == location
#          verbs << link_to(personal_connection.verb.name, verb_path(personal_connection.verb))
        end
      end
      ret += verbs.to_sentence + " at " + link_to(location.name, location)
    end
    return ret
  end

  def linked_personal_connection(personal_connection)
    s = dated_roled_person(personal_connection.person) + " " + link_to(personal_connection.verb.name, personal_connection.verb) + " at " + link_to(personal_connection.place.name, personal_connection.place)
    s += " from "+ personal_connection.started_at.year.to_s + " to " + personal_connection.ended_at.year.to_s if personal_connection.started_at && personal_connection.ended_at
    return s + "."
  end

  # Returns 'a' or 'an' depending on whether the word starts with a vowel or not
  #
  # ==== Parameters
  # <tt>name</tt> - the word
  # <tt>include_name - whether to include the name in the string output or not.
  def a_or_an(name, include_name = true)
    if name[0,1] =~ /[aeiou]/
      article = "an".html_safe
    else
      article = "a".html_safe
    end
    if include_name
      article + " ".html_safe + name
    else
      article
    end
  end

  # Returns "hasn't" or "haven't" depending on whether a number is more than 1.
  def havent_or_hasnt(number)
    if number == 1
      "hasn't"
    else
      "haven't"
    end
  end

  def pluralize_is_or_are(number, name)
    if number > 1
      word = "are"
    else
      word = "is"
    end
    return word + " " + pluralize(number, name)
  end


  # A persistant navigation link, as used in "top navs" or "left navs".
  # The main difference is that the link is replaced by a <span> tag when
  # the link would otherwise lead to the page you're already on. This can be used
  # for styling in CSS.
  def navigation_link_to(name, options = {}, html_options = {})
    if current_page?(options)
      content_tag("span", name)
    else
      link_to name, options, html_options
    end
  end

  # A (persistant) navigation link embedded within a list item.
  # === Example
  #   <%= navigation_list_link_to("Home", root_path) %>
  # Produces:
  #   <li><a href="/">Home</a></li>
  def navigation_list_link_to(name, options = {}, html_options = {})
    content_tag("li", navigation_link_to(name, options, html_options))
  end

  def pluralize_with_no(number, name)
    if number == 0
      "no " + name
    else
      pluralize(number, name)
    end
  end

  def make_slug_not_war
    self.slug = (slug.blank? ? name : slug).to_s.rstrip.lstrip.downcase.gsub(" ", "_").gsub("-", "_").gsub(",", "_").gsub(".", "_").gsub("'", "").gsub("__", "_")
  end

end
