require 'sinatra/config_file'
#CONFIG = YAML.load_file(File.dirname(__FILE__) + "/config.yml")[ENV['RACK_ENV'] || "development"]
config_file File.dirname(__FILE__) + "/config.yml"
DataMapper::Logger.new(STDOUT, :debug)
DataMapper.setup(:default, settings.development['database'])
Dir[File.dirname(__FILE__) + '/models/*.rb'].each { |model| require model }
Dir[File.dirname(__FILE__) + '/lib/**.rb'].each { |lib| require lib }

require './helpers'

class App < Sinatra::Base
  set :root, File.dirname(__FILE__)
  set :sprockets, (Sprockets::Environment.new(root) { |env| env.logger = Logger.new(STDOUT) })
  set :assets_path, File.join(root, 'assets')
  set :environments, %w{development staging production}

  configure do
    sprockets.append_path File.join(root, 'assets', 'stylesheets')
    sprockets.append_path File.join(root, 'assets', 'javascripts')
    register Sinatra::ConfigFile
    register Sinatra::Partial
  end

  configure :development do
    register Sinatra::Reloader
  end

  use BetterErrors::Middleware
  helpers Sinatra::AssetHelpers

  get "/" do
    trackings = Tracking.all
    haml :index, locals: { trackings: trackings }
  end

  put "/add" do
    content_type :json
    tid = params[:tid]
    new_tracking = Tracking.new(tid: tid)
    new_tracking.save()
    {errors: new_tracking.errors.full_messages}.to_json if new_tracking.errors.any?
    EM.synchrony do
      response = EM::Synchrony.sync DataRetriever.new(tid)
      puts response
    end
  end
end

DataMapper.finalize
