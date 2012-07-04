# -*- encoding : utf-8 -*-
require './configuration'
require 'ipaddr'

class Track < Sinatra::Base
  register Sinatra::Partial
  
  set :partial_template_engine, :slim
  
  get '/' do
    @tracks = Tracking.all.reverse
    slim :list, :layout => true, :locals => { :items => @tracks }
  end
  
  post '/' do
    @track = Tracking.create(tid: params[:tid].to_s)
    if @track.save
      slim :item, :layout => false, :locals => { :item => @track }
    else
      status 400
      { :error => @track.errors.messages }.to_json
    end
  end
  
  post '/delete' do
    @track = Tracking.where(tid: params[:id].to_s).first
    if @track.present?
      @track.destroy()
      status 200
    else
      status 404
    end
  end
  
  post '/update' do
    ip = IPAddr.new(request.ip).to_s
    @track = Tracking.where(tid: params[:id].to_s).first
    if @track.present?
      slim :item, :layout => false, :locals => { :item => @track }
    else
      last = Request.where(ip: ip).last
      if last and Time.now < (r.created_at + 10.minutes)
        status 429
      else
        Resque.enqueue(Update, ip)
      end
    end
  end
end

