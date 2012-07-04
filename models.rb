# -*- encoding : utf-8 -*-
require 'tasks/tasks'
require 'mongoid'
class Status
    include Mongoid::Document
    
    field :status, type: String
    field :date, type: String
    field :origin, type: String
    field :postcode, type: String, default: ''
    
    embedded_in :tracking
end

class Tracking
    include Mongoid::Document
    validates_format_of :tid, with: /[a-zA-Z]{2}\d{9}[a-zA-Z]{2}/
    validates_uniqueness_of :tid
    validates_presence_of :tid
    field :tid, type: String
    field :progress, type: Float
    embeds_many :statuses
    
    def postcodes?
      self.statuses.map(&:postcode).reject(&:empty?).any?
    end
    
    def postcodes
      self.statuses.map(&:postcodes).reject(&:empty?)
    end
    
    after_create do |t|
      t.statuses.push(Status.new(status: 'Новая'))
      Resque.enqueue_to(:requests, UpdateEach, t.tid)
    end
end

class Request
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  field :ip, type: String
  field :request, type: String
end