# -*- encoding : utf-8 -*-
require './configuration'
require 'ipaddr'
require "sinatra/streaming"
require 'json/ext'

module Tracker
  class Web < Sinatra::Base
    connections = []
    helpers Sinatra::Streaming
    register Sinatra::Partial
    
    def self.pack_event(event, data)
      obj = ""
      obj << "event: #{event.to_s}\n"
      obj << "data: #{data.to_s}\n\n"
      obj
    end
    
    set :partial_template_engine, :slim
    
    get '/' do
      @tracks = Tracking.all.sort { |f,s| f.statuses.last.date <=> s.statuses.last.date }.reverse
      @updates = Refresh.all.limit(5).order_by(:time, :desc)
      slim :list, :layout => true, :locals => { :items => @tracks, :updates => @updates }
    end
  
    put '/' do
      @track = Tracking.create(tid: params[:tid].to_s)
      if @track.save
        slim :item, :layout => false, :locals => { :item => @track }
      else
        status 400
        { :error => @track.errors.messages }.to_json
      end
    end
  
    delete '/' do
      @track = Tracking.where(tid: params[:id].to_s).first
      if @track.present?
        @track.destroy()
        status 200
      else
        status 404
      end
    end
  
    get '/update' do
      ip = IPAddr.new(request.ip).to_s
      last = Request.where(ip: ip).last
      if !last and Time.now < (last.created_at + 2.minutes)
        status 429
      else
        if params[:id].present? && Tracking.where(tid: params[:id].to_s).first.present?
          track = Tracking.where(tid: params[:id].to_s).first
          UpdateEach.perform_async(track.tid)    
        else
          Update.perform_async(ip)
        end
      end
    end
    
    get '/refresh' do
      @track = Tracking.where(tid: params[:id].to_s).first
      slim :item, :layout => false, :locals => { :item => @track }
    end
    
    get '/poll' do  
      content_type 'text/event-stream'
      stream :keep_open do |stream|
        connections << stream
        stream.callback { connections.delete(stream) }
      end
    end 
    
    Thread.new do
      redis = Redis.new
      redis.subscribe('update') do |on|
        on.message do |channel, message|
          connections.each do |stream|
            object = pack_event(channel,message)
            stream << object
          end
        end
      end
    end
    
  end
end