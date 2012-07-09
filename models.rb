# -*- encoding : utf-8 -*-
  class Status
    include Mongoid::Document
        
    field :status, type: String
    field :date, type: String, default: ''
    field :origin, type: String, default: ''
    field :postcode, type: String, default: ''
  
    embedded_in :tracking
end

class Tracking
    include Mongoid::Document
    include Mongoid::Timestamps::Updated
    store_in :trackings
    
    validates_format_of :tid, with: /[a-zA-Z]{2}\d{9}[a-zA-Z]{2}/
    validates_uniqueness_of :tid
    validates_presence_of :tid
    
    field :tid, type: String
    field :progress, type: Float
  
    embeds_many :statuses
  
    def postcodes?
      statuses.map(&:postcode).reject(&:empty?).any?
    end
  
    def postcodes
      statuses.map(&:postcodes).reject(&:empty?)
    end
    
    def self.updated
      self.all.reject { |t| t.updated_at < (Time.now - 20.seconds) }.map { |t| 
        { 
          key: t.tid,
          progress: t.progress 
          statuses: 
        }
        [t.tid, t.progress, t.statuses.map { |s| [s.status, (DateTime.parse(s.date).strftime('%d/%m/%Y') or nil), s.origin, s.postcode] }] 
      }
    end
    
    before_save do |t|
      t.updated_at = Time.now
    end
    after_create do |t|
      t.statuses.push(Status.new(status: 'Новая'))
      Resque.enqueue_to(:requests, UpdateEach, t.tid)
    end
end

class Request
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  store_in :requests

  field :ip, type: String
  field :request, type: String
end