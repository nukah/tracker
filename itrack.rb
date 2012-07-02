require './configuration'

class Track < Sinatra::Base  
  get '/' do
    @tracks = Tracking.all
    erb :list, :layout => true, :locals => { :items => @tracks }
  end
  
  post '/' do
    @tracking = Tracking.new(tid: params[:tid].to_s)
    if @tracking.save
      erb :item, :layout => false
    else
      status 400
      { :error => @tracking.errors.messages }.to_json
    end
  end
  
  delete '/' do
    @tracking = Tracking.where(_id: params[:id].to_s).first
    if @tracking.present?
      @tracking.destroy()
      status 200
    else
      status 404
    end
  end
  
  get '/update' do
    
  end
  
  get '/update/:id' do
    
  end
end