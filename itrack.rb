# -*- encoding : utf-8 -*-
require './configuration'
require 'ipaddr'
require 'sinatra/async'

module Tracker
  class Web < Sinatra::Base
    register Sinatra::Partial
    register Sinatra::Async
    
    set :partial_template_engine, :slim
    
    aget '/i' do
      @tracks = Tracking.all
      EM.add_timer(20) {
      body {
          Tracking.updated.to_json
        }
      }
    end
    
    get '/' do
      @tracks = Tracking.all.sort { |f,s| f.updated_at <=> s.updated_at }.reverse
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
        if last and Time.now < (last.created_at + 10.minutes)
          status 429
        else
          Resque.enqueue(Update, ip)
        end
      end
    end
  end
end