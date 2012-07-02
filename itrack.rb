require './configuration'

class Track < Sinatra::Base
  register Sinatra::Partial
  
  set :partial_template_engine, :erb  
  
  get '/' do
    @tracks = Tracking.all
    erb :list, :layout => true, :locals => { :items => @tracks }
  end
  
  post '/' do
    @track = Tracking.create(tid: params[:tid].to_s)
    if @track.save
      erb :item, :layout => false, :locals => { :item => @track }
    else
      status 400
      { :error => @track.errors.messages }.to_json
    end
  end
  
  delete '/' do
    @track = Tracking.where(_id: params[:id].to_s).first
    if @track.present?
      @track.destroy()
      status 200
    else
      status 404
    end
  end
  
  get '/update/:id' do
    
  end
end