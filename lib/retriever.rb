#!/usr/bin/env ruby
require 'nokogiri'
require 'em-http-request'
require 'em-synchrony'
require "em-synchrony/fiber_iterator"
require 'base64'

class DataRetriever
  include EM::Deferrable
  MAX_ATTEMPTS = 5
  def initialize tid
    url = "http://www.russianpost.ru/resp_engine.aspx?Path=rp/servise/ru/home/postuslug/trackingpo"
    body = EM::Synchrony.sync ClearRequest.new(url)
    puts body
    history = {}
    image_id, image_url = body.css("#CaptchaId").attr("value").value, body.css("#captchaImage").attr("src").value
    image_request = EM::Synchrony.sync EM::HttpRequest.new(image_url).get
    image = Base64.strict_encode64(image_request.response)
    resolver = EM::Synchrony.sync CaptchaResolver.new(image_id, image)
    tracking_request = EM::Synchrony.sync EM::HttpRequest.new(url).post :body => {'BarCode' => tid, 'searchsign' => 1, 'CaptchaId' => image_id, 'InputedCaptchaCode' => resolver }
    tracking_history = Nokogiri::HTML(tracking_request.response)
    tracking_history.css(".pagetext tbody > tr").collect { |list| list.css('td').collect { |row| row.inner_text }}.each do |element|
      status, date = element[0].to_s, element[1].to_s
      history.store(status,date)
    end
    puts "Processing #{tid} -> #{history}"
    self.succeed(history)
  end
end

class CaptchaResolver
  include EM::Deferrable
  def initialize captcha, image
    send_url = "http://antigate.com/in.php"
    resolve_url = "http://antigate.com/res.php"
    send_captcha = EM::Synchrony.sync EM::HttpRequest.new(send_url).post :query => { 'method' => 'base64', 'key' => '078a3767d89166e344255a7f949d7bb1', 'body' => image, 'numeric' => 1 }

    if send_captcha.response =~ /OK/
      _, id = send_captcha.response.split('|')
      captcha_poll = EM::Synchrony.add_periodic_timer(5) {
        captcha_retrieve = EM::Synchrony.sync EM::HttpRequest.new(resolve_url).get :query => {key: '078a3767d89166e344255a7f949d7bb1', action: 'get', id: id }  
        if captcha_retrieve.response =~ /OK/
          _, result = captcha_retrieve.response.split('|')
          captcha_poll.cancel
          self.succeed(result)
        end  
      }
    else
      self.fail(send_captcha.response)
    end                                                           
  end
end

class ClearRequest
  include EM::Deferrable
  def initialize url
    passing_timer = EM::Synchrony.add_periodic_timer(2) {
      request = EM::Synchrony.sync EM::HttpRequest.new(url).get
      body = Nokogiri::HTML(request.response)
      if body.search("form[name=myform]").any?
        key = body.search("input[name=key]").attr("value").value
        post_request = EM::Synchrony.sync EM::HttpRequest.new(url).post :body => {'key' => key }
      else
        passing_timer.cancel
        self.succeed(body)
      end
      false
    }
  end
end

file_name = ARGV[0]
pattern = /([a-zA-Z]{2}\d{9}[a-zA-Z]{2})/
begin
  list = File.open(file_name) if File.file?(file_name) or raise Exception, "Wrong filename."
rescue Exception => e
  puts e.message
  exit
end
found_ids = []
list.each_line { |l| if l.match(pattern) then found_ids << l.match(pattern)[0] end }
EM.synchrony do
  r = EM::Synchrony::FiberIterator.new(found_ids, 3).map do |id|
    DataRetriever.new(id)
  end
  puts r
  EM.stop
end
