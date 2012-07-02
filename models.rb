require 'mongoid'

class Tracking
    include Mongoid::Document
    validates_format_of :tid, with: /[a-zA-Z]{2}\d{9}[a-zA-Z]{2}/
    validates_uniqueness_of :tid
    validates_presence_of :tid
    field :tid, type: String
    field :status, type: String
    field :updated, type: DateTime, default: ->{ Time.now }
    field :country, type: String
end
