# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
Mime::Type.register_alias "application/x-blueprint+xml", :bp
Mime::Type.register 'application/vnd.google-earth.kml+xml', :kml
Mime::Type.register 'text/plain', :poi
Mime::Type.register 'application/rss+xml', :georss
Mime::Type.register 'application/osm+xml', :osm