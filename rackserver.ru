require './lib/finder_api.rb'
require 'logger'
require 'yaml'

class API 
  @@logger=nil
  def logger
    if(@@logger==nil)
      @@logger = Logger.new(STDOUT)
      case config["logger_level"]
        when "debug"
          @@logger.level = Logger::DEBUG
        when "info"
          @@logger.level = Logger::INFO
        when "warn"
          @@logger.level = Logger::WARN
        when "error"
          @@logger.level = Logger::ERROR
        else
          @@logger.level = Logger::FATAL
      end
      @@logger.debug "Logger has started. (first request received)"
    end
    @@logger
  end
  def root_path
    @@root_path ||=File.dirname(caller[0].split(":")[0])
  end
  
  def config
    @@config ||= YAML.load_file(File.join("config","config.yml"))
  end
  
  def finder_api
  	@@finder_api ||= FinderAPI.new(:logger => logger, 
  	:root_path => root_path,
  	:xsd => Nokogiri::XML::Schema(File.read(config["finder_xsd"])),
  	:public_options_data => Nokogiri::XML(File.read(config["db_file"])),
  	:territory_data => Nokogiri::XML(File.read(config["territory_file"])),
  	:rbis => RbisServiceV3::RbisInterfaceV3.new(:base_url=>config["rbis_url"],:xsd_path => config["rbis_xsd"],:logger=>logger))
  end
  
  def call(env) 
    ts = Time.now
    req = Rack::Request.new(env)
    req_xml = req.body.read
    logger.debug "Request Environemt:"+env.inspect 
  	if req.post? && req.content_type == 'application/xml'
      res = finder_api.process_request(req_xml) 
    elsif req.get?
      res =["301", {"Content-Type"=>"text/html", "Location"=>"http://finder.healthcare.gov/services"},[""]]
    elsif env["REQUEST_METHOD"].downcase == "options"
      res =["200", {"Content-Type"=> "text/html"},[""]]
    else
  	  res =["500",{"Content-Type"=> "text/html"},["Error: Request not POST of type 'application/xml'"]]
   	end
   	te = Time.now
   	logger.info "Method:#{env["REQUEST_METHOD"]} TO:#{env["REQUEST_URI"]} FROM:#{env["REMOTE_ADDR"]} - #{env["REMOTE_HOST"]} RESCODE:#{res[0]} ET:#{te-ts}"
   	if(res[0]== "200" || res[0] == "400")
      logger.debug "*************ENVIRONMENT*****************"
      logger.debug env
      logger.debug "***************REQUEST*******************"
      logger.debug req_xml.gsub(/\>[\n\s]*</, "><")
      logger.debug "***************RESPONSE******************"
      logger.debug res
      logger.debug "===================================END OF REQUEST============================================="
      logger.debug "=============================================================================================="
    elsif (res[0]== "500")
      logger.error "*************ENVIRONMENT*****************"
      logger.error env
      logger.error "***************REQUEST*******************"
      logger.error req_xml.gsub(/\>[\n\s]*</, "><")
      logger.error "***************RESPONSE******************"
      logger.error res
      logger.error "===================================END OF REQUEST============================================="
      logger.error "=============================================================================================="
    end
    res
  end 
  
end 
run API.new
