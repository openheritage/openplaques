require 'rubygems'
#require 'open-uri'
require 'net/http'
require 'uri'
#require 'clip'
require 'cgi'

namespace "muddy" do
  desc "Identify DBpedia references for the content"
  task :identify => [:environment] do 
    puts "Identifying content..."
    
    site = "staging.muddy.it"
    
    username = "frankieroberto"
    password = "blueplaques"
    token = "d3a6696a-1bee-4221-b24c-a1c79821481a"
    
    
    doc = {}
    #doc[:text] = "The British National Party could pose a major threat to Labour in the upcoming European elections, Labour's deputy leader Harriet Harman has said."
    #doc[:uri] = "http://news.bbc.co.uk/1/hi/world/africa/7992779.stm"
    doc[:include_content] = 'true' #if options.debug
    doc[:realtime] = 'true' #if options.realtime
    #doc[:identifier] = "HHHHSS"  #options.identifier
    #doc[:extraction_match] = options.match if options.match
    #doc[:extended_response] = 'true'
    #doc[:include_related] = 'true'
    doc[:include_content] = 'false'
    doc[:include_unclassified] = 'true'
    doc[:disambiguate] = 'true'
    doc[:store] = 'true'
    #doc[:content_extractor] = 'BBCBitesize'

    #puts doc.inspect
    
    u = "http://#{site}/api/sites/#{token}/pages/categorise"
    #puts u
    url = URI.parse(u)
    req = Net::HTTP::Post.new(url.path, { "Accept" => "application/json", "User-Agent" => "muddy.it" })
    req.basic_auth username, password
    
    people = Person.find(:all)
    
    people.each do |person|
      
      doc[:text] = person.name
      doc[:identifier] = person.id.to_s
      
      puts doc.inspect
      req.set_form_data(doc)
    
      http = Net::HTTP.new(url.host, url.port)
      http.open_timeout = 160
      http.read_timeout = 160
      http.start do |http|
        res = http.request(req)
        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          puts res.body
        else
          #puts res.error!
          puts res.body
        end
      end

    end
    
  end

  desc "Test"
  task :test => [:environment] do

    
    u = "http://staging.muddy.it/demos/bbc"
    doc = {}
    doc[:text] = "Gordon Brown Prime Minister"
    doc["submit.x"] = "57"
    doc["submit.y"] = "-21"    
    
    url = URI.parse(u)
    req = Net::HTTP::Post.new(url.path, { "Accept" => "application/json", "User-Agent" => "muddy.it" })
    req.set_form_data(doc)

    http = Net::HTTP.new(url.host, url.port)
    http.open_timeout = 160
    http.read_timeout = 160
    http.start do |http|
      res = http.request(req)
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        puts res.body
      else
        #puts res.error!
        puts res.body
      end
    end
    
    
  end
  
end