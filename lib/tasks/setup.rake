
namespace "setup" do
  desc "Creates an admin account"
  task :create_admin => [:environment] do
    user = User.new(:username => "admin", :password => "changeme", :password_confirmation => "changeme", :email => "change@me.com")
    if user.save
      user.make_admin
      puts "Admin user created"
    else
      puts user.errors.full_messages.to_s
    end
  end
  
end