# -*- encoding : utf-8 -*-
require 'mongoid'
class Status
    include Mongoid::Document
    
    field :status, type: String
    field :date, type: String
    field :origin, type: String
    field :postcode, type: String
    
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
    
    after_create do |t|
      t.statuses.push(Status.new(status: 'New', date: Time.now.strftime("%-d/%-m/%Y")))
    end
end

