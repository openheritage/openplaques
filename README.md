h1. Welcome to Open Plaques

Open Plaques is a service that aims to find and provide data about all the commemorative 'plaques' (often blue and round) that can be found across the UK and worldwide.

The website is written in Ruby on Rails (http://rubyonrails.org/), a web application framework which is written in the Ruby programming language (http://www.ruby-lang.org/en/).

h2. Installation requirements

To run this website, you will need to have the following bits of software installed:

* Ruby
* Ruby on Rails
* A database server - either PostGres (preferred) or SQLite

h2. Getting Started

To run the website, you will need to do the following first:

# Copy database.example.yml to database.yml in the config/ folder. If you're using PostGres, you'll need to edit the details to point at your MySQL database. Otherwise you can leave it as it is in order to use SQLite.
# Copy environment.example.rb to environment.rb in the config/ folder. You won't need to edit anything to get started, though in order to use the Flickr import feature or geolocation features, you'll have to register with the different services and copy in your API keys.
# From the command line, run <tt>bundle install</tt> to install a few required ruby gems.
# From the command line, run <tt>bundle exec rake db:setup</tt> in order to set up your database and setup initial data.
# From the command line, run <tt>bundle exec rails server</tt> in order to start the web server (Mongrel will be used by default). You should then be able to see the website at http://0.0.0.0:3000 (or whichever URL is specified at the command line).

h2. Making Contributions

We really welcome contributions to this project, whether they are simple bug fixes, user interface improvements, or new ways for people to access the data.

The simplest way to contribute is to fork this project on GitHub, make your changes, and then submit a Pull Request.

If you have an idea for a major new feature, or for some changes to the actual database, it may be best to discuss the idea with the community first. You can do so by creating an Issue for your suggested change. 
