source :rubygems

gem 'sinatra'
gem 'sinatra-partial'
gem 'slim'
gem 'mongo-resque', :require => 'resque'
gem 'resque-mongo-scheduler', :git => 'git://github.com/nukah/resque-mongo-scheduler.git', :require => 'resque_scheduler'
gem 'mongoid'
gem 'bson',     '1.6.2'
gem 'bson_ext', '1.6.2'
gem 'rack-session-mongo'
gem 'nokogiri'

group :production do
    gem 'unicorn'
end

group :development do
    gem 'pry'
    gem 'thin'
end

group :test do
    gem 'rspec'
    gem 'capybara'
    gem 'machinist'
    gem 'machinist_mongo', :git => 'git://github.com/nmerouze/machinist_mongo.git', :branch   => 'machinist2'
    gem 'faker'
end
