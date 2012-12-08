require 'dm-core'
require 'dm-validations'

class Tracking
  include DataMapper::Resource
  
  validates_format_of :tid, with: /[a-zA-Z]{2}\d{9}[a-zA-Z]{2}/
  validates_uniqueness_of :tid
  validates_presence_of :tid

  property :id, Serial
  property :tid, String
  property :updated_at, DateTime
  property :status, String
end