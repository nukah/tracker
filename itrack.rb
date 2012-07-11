# -*- encoding : utf-8 -*-
require './configuration'
require 'ipaddr'
require 'sinatra/async'
require 'json/ext'

module Tracker
  class Web < Sinatra::Base
    use Rack::Deflater
    register Sinatra::Partial
    register Sinatra::Async
    
    set :partial_template_engine, :slim
    
    aget '/poll' do
      content_type :json
      EM.add_timer(10) {
        sync = Time.at(params[:time].to_i)
        response = Refresh.where(:time.gt => (sync - 5.seconds)).map(&:tid).to_json
        body { response }
      }
    end
    
    get '/' do
      @tracks = Tracking.all.sort { |f,s| f.statuses.last.date <=> s.statuses.last.date }.reverse
      @updates = Refresh.all.limit(5).order_by(:time, :desc)
      slim :list, :layout => true, :locals => { :items => @tracks, :updates => @updates }
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
        if last and Time.now < (last.created_at + 10.minutes)
          status 429
        else
          Resque.enqueue(Update, ip)
        end
      end
    end
  end
end