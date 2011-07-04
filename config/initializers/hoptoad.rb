HoptoadNotifier.configure do |config|
  config.api_key = ENV['HOPTOAD_KEY'] if !(ENV['HOPTOAD_KEY'].nil?)
end
