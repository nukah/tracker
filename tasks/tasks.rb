# -*- encoding : utf-8 -*-
require 'nokogiri'
require 'net/http'

LOGGER = Logger.new(STDOUT)

class Update
  @queue = :requests
  def self.perform(ip = nil)
    Request.create!(ip: ip) if ip
    Tracking.find(:all).each { |tracking| Resque.enqueue_to(:requests, UpdateEach, tracking.tid) }
  end
end

class UpdateEach
  @queue = :requests
  PROGRESS = {
    'Приём'   => 0.1,
    'Экспорт' => 0.2,
    'Импорт'  => 0.3,
    'Таможенное оформление завершено' => 0.4,
    'Обработка' => 0.5,
    'Вручение'  => 0.7
  }
  @url = URI("http://www.russianpost.ru/resp_engine.aspx?Path=rp/servise/en/home/postuslug/trackingpo")
  def self.perform(id)
    redis = Settings.redis
    updated = false
    tracking = Tracking.where(:tid => id).first
    LOGGER.info("New request for #{tracking.tid}")
    document = Nokogiri::HTML(Net::HTTP.post_form(@url, 'BarCode' => tracking.tid, 'searchsign' => 1).body)
    rows = document.css('table.pagetext > tbody tr').collect { |row| row.css('td').collect { |cell| cell.inner_text } }
    rows.reject { |row| tracking.statuses.collect(&:status).include?(row[0]) }.each do |row|
      status, date, code, origin = row[0].to_s, row[1].to_s, row[2].to_s, row[3].to_s
      tracking.progress = PROGRESS[status] if PROGRESS.has_key?(status)
      status = Status.new(status: status, postcode: code, date: DateTime.parse(date).strftime("%d/%m/%Y"), origin: origin)
      LOGGER.info("#{Time.now.getlocal}: Substatus update: #{status.to_str}")
      tracking.save
      tracking.statuses.push(status)
      updated = true
    end
    redis.publish('update', id)
    LOGGER.info("Request completed succesfully.")
  end
end

