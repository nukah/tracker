# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'net/http'

class Update
  @queue = :requests
  def self.perform
    Tracking.find(:all).each { |tracking| Resque.enqueue(UpdateEach, tracking.tid) }
  end
end

class UpdateEach
  PROGRESS = {
    'Приём'   => 0.1,
    'Импорт'  => 0.3,
    'Обработка' => 0.5,
    'Вручение'  => 0.7
  }
  @url = URI("http://www.russianpost.ru/resp_engine.aspx?Path=rp/servise/en/home/postuslug/trackingpo")
  def self.perform(id)
    tracking = Tracking.where(:tid => id).first
    document = Nokogiri::HTML(Net::HTTP.post_form(@url, 'BarCode' => tracking.tid, 'searchsign' => 1).body)
    rows = document.css('table.pagetext > tbody tr').collect { |row| row.css('td').collect { |cell| cell.inner_text } }
    rows.reject { |row| tracking.statuses.collect(&:status).include?(row[0]) }.each do |row|
      status, date, code, origin = row[0], row[1], row[2], row[3]
      tracking.progress = PROGRESS[status] if PROGRESS.has_key?(status)
      tracking.save
      tracking.statuses.push(Status.new(status: status, postcode: code, date: DateTime.parse(date).strftime("%-d/%-m/%Y"), origin: origin))
    end
  end
end

