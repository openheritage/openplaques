desc "This task runs all of the other tasks which should be run daily"
task :cron => [:environment, "photos:find"] do
end
