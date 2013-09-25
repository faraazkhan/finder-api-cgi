require 'net/https'
require 'uri'

module BmilzUtils
  module AcceptAttributeHash
    def self.included(base)
      base.extend(self)
    end
    
    def initialize(attr_hash = {})
      super()
      attr_hash.each_pair do |k,v|
        send("#{k.to_s}=",v)
      end
    end
  end
  
  module RandomUtils
    #accepts a string, checks for a valid http protocol and adds it if missing (returns string || http://+string)
    def self.fix_url_protocol(url_string)
      unless url_string.blank?
        url_string = url_string.to_s.strip
        url_string = "http://" + url_string unless url_string[/\Ahttp(s)*:\/\/.*/i]
        url_string.gsub!(/http:/i, "http:")
        url_string.gsub!(/https:/i, "https:")
        
        unless url_string =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
          url_string = nil
        end
      end
      url_string
    end
    
    def self.valid_date?(month, day, year)
      begin
        Time.mktime(year.to_i, month.to_i, day.to_i, 0, 0, 0) 
        true
      rescue ArgumentError
        false 
      end
    end
    
    def self.stringify_int(int)
      case int
      when 0
        "zero"
      when 1
        "one"
      when 2
        "two"
      when 3
        "three"
      when 4
        "four"
      when 5
        "five"
      when 6
        "six"
      when 7
        "seven"
      when 8
        "eight"
      when 9
        "nine"
      else
        nil
      end
    end
    
    class HttpsHelper
      include BmilzUtils::AcceptAttributeHash
      
      attr_accessor(:verify_cert)
      attr_accessor(:cert_path)
      attr_accessor(:logger)
      def verify_cert
        @verify_cert ||= false
      end
      
      def logger
        @logger
      end
      def cert_path
        @cert_path ||= File.join(File.dirname(__FILE__), "cacert.pem")
      end
      
      def make_https_call(url_as_string, method='GET', request_params=nil)
#        puts url_as_string if Rails.env == 'development'
        
        logger.debug request_params
        uri = URI.parse(url_as_string)
        http = Net::HTTP.new(uri.host, uri.port)
        response = nil
        if uri.scheme == "https"  # enable SSL/TLS
          http.use_ssl = true
          if verify_cert
            http.verify_mode = OpenSSL::SSL::VERIFY_PEER
            http.ca_file = cert_path
          else
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
        end
        st = Time.now
        http.start {
          if method == 'POST'
            http.post2(uri.request_uri, request_params, {'Content-Type' => 'application/xml'}) {|res|
              unless res.code == "200"
                logger.error "Error making call #{res.code} with #{url_as_string} - params: #{request_params} - response: #{res.body}"
                raise "RandomUtils::HttpsHelper#make_http_call - got HTTP code #{res.code}"
              end
              response = res.body
            }
          else
            http.request_get(uri.request_uri) {|res|
              unless res.code == "200"
                logger.error "Error making call #{res.code} with #{url_as_string}"
                raise "RandomUtils::HttpsHelper#make_http_call - got HTTP code #{res.code}"
              end
              response = res.body
            }
          end
        }
        et = Time.now
#        puts "Web Service Responded in - #{et - st}" if Rails.env == "development"
        response
      end
    end
  end
end