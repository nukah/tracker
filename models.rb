# -*- encoding : utf-8 -*-
  class Status
    include Mongoid::Document
        
    field :status, type: String
    field :date, type: String, default: ""
    field :origin, type: String, default: ""
    field :postcode, type: String, default: ""
  
    embedded_in :tracking
    
    def to_str
      "#{self.status} @ #{self.date} in #{self.origin}##{self.postcode}"
    end
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
    
    before_save do |t|
      t.updated_at = Time.now.getlocal
    end
    after_create do |t|
      t.statuses.push(Status.new(status: 'Новая'))
      UpdateEach.perform_async(t.tid)
    end
end

class Request
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  
  store_in :requests

  field :ip, type: String
  field :request, type: String
end

class Refresh
  include Mongoid::Document
  
  store_in :refreshes
  field :time, type: DateTime, default: Time.now.getlocal
  field :tid, type: String
end