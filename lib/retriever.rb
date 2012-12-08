require 'nokogiri'
require 'eventmachine'
require 'curb'
require 'base64'

class DataRetriever
  include EM::Deferrable
  def initialize tid
    url = "http://www.russianpost.ru/rp/servise/ru/home/postuslug/trackingpo"
    russian_post_request = Curl.get(url)
    russian_post_request.callback {
      body = Nokogiri::HTML(russian_post_request.response)
      image_id, image_url = body.css("#CaptchaId").attr("value").value, body.css("#captchaImage").attr("src").value
      image_request = EM::HttpRequest.new(image_url).get
      image_request.callback {
        captcha_image = Base64.strict_encode64(image_request.response)
        puts "Image encoded processing to resolve"
        #resolver = CaptchaResolver.new(id, captcha_image)

        resolver.callback { |captcha|
          puts "Captcha has been resolved, result is #{captcha}"
          tracking_history = Faraday.post :url => url, :query => {'BarCode' => tracking_id, 'searchsign' => 1, 'CaptchaId' => id, 'InputedCaptchaCode' => captcha }

          tracking_history.callback {
            puts "Sorting out results"
            page = Nokogiri::HTML(tracking_history.response)
            history = {}
            result_page.css(".pagetext").collect { |row| row.css('td').collect { |cell| cell.inner_text }}.each do |row|
              status, date = row[0].to_s, row[1].to_s
              history.store(status,date)
            end
            puts "Result is ready"
            self.succeed(history)
          }
        }
      }
    }
  end
end

class CaptchaResolver
  include EM::Deferrable
  def initialize captcha, image
    send_url = "http://antigate.com/in.php"
    resolve_url = "http://antigate.com/res.php"
    puts "<CaptchaResolver> Preparing to send image of #{captcha} to Antigate"
    captcha_send = Faraday.post :url => send_url, :query => { 'method' => 'base64', 
                                                               'key' => '078a3767d89166e344255a7f949d7bb1', 
                                                               'body' => @image,
                                                               'numeric' => 1,
                                                              }
    captcha_send.callback {
      puts "<CaptchaResolver> Got result, #{captcha_send.response}"
      if captcha_send.response =~ /OK/
        _, id = captcha_send.response.split('|')
        puts "<CaptchaResolver> Got OK result, id of resolving captcha is #{id}. Processing to get status"
        captcha_retrieve = Faraday.get :url => resolve_url, :query => { 'key' => '078a3767d89166e344255a7f949d7bb1',
                                                         'action' => 'get',
                                                         'id' => id
                                                                          }
        captcha_retrieve.callback {
          puts "<CaptchaResolver> Got result for status. Response is #{captcha_retrieve.response}"
          if captcha_retrieve.response =~ /OK/
            _, result = captcha_retrieve.response.split('|')
            self.succeed(result)
          elsif captcha_retrieve.response =~ /CAPCHA_NOT_READY/
            sleep 5
            captcha_retrieve = Faraday.get :url => resolve_url, :query => { 'key' => '078a3767d89166e344255a7f949d7bb1',
                                                             'action' => 'get',
                                                             'id' => id
                                                                              }
          else
            self.fail(captcha_retrieve.response)
          end
        }        
      else 
        self.fail(captcha_send.response)
      end
    }                                                              
  end
end