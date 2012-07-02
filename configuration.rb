$:.push(Dir.getwd())
require 'sinatra'
require 'models'
require 'resque'
require 'mongoid'
require 'rack-session-mongo'
require 'sinatra/partial'

@c = YAML::load(File.open('config/configuration.yml'))

host,port = @c['datastore']['host'].split(':')
Resque.mongo = Mongo::Connection.new(host,port).db(@c['datastore']['jobs'])

configure do 
  
  Mongoid.configure do |config|
    config.master = Mongo::Connection.new(host, port, :pool_size => 3).db(@c['datastore']['models'])
  end
  
  use Rack::Session::Mongo, {
    :host     => "#{host}:#{port}",
    :db_name  => "#{@c['datastore']['sessions']}",
    :expire_after => 600
  }
  
  settings.default_encoding = "utf-8"
  settings.views = "views/"
  enable :logging
end

configure :development do
  $logger = Logger.new(STDOUT)
end