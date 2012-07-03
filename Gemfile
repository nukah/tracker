source :rubygems

gem 'sinatra'
gem 'mongo-resque', :require => 'resque'
gem 'bson',     '1.6.2'
gem 'bson_ext', '1.6.2'
gem 'resque-mongo-scheduler', :git => 'git://github.com/nukah/resque-mongo-scheduler.git', :require => 'resque_scheduler'
gem 'rack-session-mongo'
gem 'mongoid'
gem 'nokogiri'
gem 'slim'
gem 'sinatra-partial'

group :production do
    gem 'unicorn'
end

group :development do
    gem 'pry'
end

group :test do
    gem 'rspec'
    gem 'capybara'
    gem 'machinist'
    gem 'machinist_mongo', :git => 'git://github.com/nmerouze/machinist_mongo.git', :branch   => 'machinist2'
    gem 'faker'
end
