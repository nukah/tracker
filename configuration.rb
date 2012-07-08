# -*- encoding : utf-8 -*-
$:.push(Dir.getwd())
require 'bundler/setup'
Bundler.require(:default)
require 'ostruct'
require 'models'
require 'tasks/tasks'

module Tracker
  settings_array = OpenStruct.new(YAML.load(File.open('config/configuration.yml')))
  Kernel.const_set('Settings', settings_array) if !Tracker.const_defined?('Settings')
  
  host,port = Settings.data_host, Settings.data_port
  connection = Mongo::Connection.new(host, port)

  configure do 
    Resque.mongo = connection.db(Settings.jobs)
    Mongoid.configure do |c|
      c.master = connection.db(Settings.models)
    end
  
    settings.default_encoding = "utf-8"
    settings.views = "views/"
    enable :logging
  end

  configure :development do
    $logger = Logger.new(STDOUT)
  end

end