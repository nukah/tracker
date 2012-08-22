# -*- encoding : utf-8 -*-
$:.push(Dir.getwd())
require 'bundler/setup'
Bundler.require(:default)
require 'ostruct'
require 'models'
require 'tasks/tasks'

include Rake::DSL
settings_array = OpenStruct.new(YAML.load(File.open('config/configuration.yml')))
Kernel.const_set('Settings', settings_array) if !Kernel.const_defined?('Settings')

mongo = Mongo::Connection.new(Settings.host, Settings.port)
redis = Redis.new(:host => Settings.rhost, :port => Settings.rport)

Sidekiq.configure_server do |config|
  config.redis = { :url => "redis://#{Settings.rhost}:#{Settings.rport}", :namespace => 'resque' }
end
Sidekiq.configure_client do |config|
  config.redis = { :url => "redis://#{Settings.rhost}:#{Settings.rport}", :namespace => 'resque' }
end

Mongoid.configure do |c|
    c.master = mongo.db(Settings.models)
end

configure do 	
  settings.default_encoding = "utf-8"
  settings.views = "views/"
  enable :logging
end

configure :development do
  $logger = Logger.new(STDOUT)
end
