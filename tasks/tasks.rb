require 'resque/tasks'
require '../models'
require 'nokogiri'
require 'net/http'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new(host, port, :pool_size => 3).db(@c['datastore']['models'])
end

class Update
  @queue = :requests
  @url = URI("http://www.russianpost.ru/resp_engine.aspx?Path=rp/servise/en/home/postuslug/trackingpo")
  def self.perform(id)
    tracking = Tracking.where(:tid => id).first
    document = Nokogiri::HTML(Net::HTTP.post_form(@url, 'BarCode' => tracking.tid, 'searchsign' => 1).body)
    time = Time.now
    objects = document.css('table.pagetext > tbody tr:last')
  end
end