Welcome to Open Plaques
=======================

Open Plaques is a service that aims to find and provide data about all the commemorative 'plaques' (often blue and round) that can be found across the UK and worldwide.

The website is written in [Ruby on Rails](http://rubyonrails.org/), a web application framework which is written in the Ruby programming language (http://www.ruby-lang.org/en/).

Installation requirements
-------------------------

To run this website, you will need to have the following bits of software installed:

* Ruby, version 2.0.0
* [Bundler](http://bundler.io) 
* A database server - either PostGres (preferred) or SQLite

Further dependencies are managed using Bundler, which will install them for you. These include things
like Rails and a JSON library.

Getting Started
---------------

To run the website, you will need to do the following first:

1. Copy `database.example.yml` to `database.yml` in the `config/` folder. If you're using PostGres, you can leave it as it is – just make sure that you’ve created a local database called `openplaques` which doesn't require a username or password. You should also create a second database called `openplaques_test` in order to run the tests. If for some reason you can’t use PostGres, you can edit the file to specify a MySQL or SQLite3 connection.
2. From the command line, run `bundle install` to install a few required ruby gems.
3. From the command line, run `bundle exec rake db:setup` in order to set up your database and setup initial data.
4. From the command line, run `bundle exec rails server` in order to start the web server (Mongrel will be used by default). You should then be able to see the website at `http://0.0.0.0:3000` (or whichever URL is specified at the command line).

Making Contributions
--------------------

We really welcome contributions to this project, whether they are simple bug fixes, user interface improvements, or new ways for people to access the data.

The simplest way to contribute is to fork this project on GitHub, make your changes, and then submit a Pull Request.

If you have an idea for a major new feature, or for some changes to the actual database, it may be best to discuss the idea with the community first. You can do so by creating an Issue for your suggested change. 
