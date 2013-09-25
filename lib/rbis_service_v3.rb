#this library is designed to simplify communications with CGI's RBIS service
#RBIS service will returns a XML response based on the XSD

#require 'bmilz_utils'
require 'nokogiri'
require_relative 'bmilz_utils'

module RbisServiceV3
  
  
  class RbisInterfaceV3
    
    include BmilzUtils::AcceptAttributeHash
    
    attr_accessor(:base_url)
    def base_url
      @base_url
    end
    
    attr_accessor(:http_requestor)
    def http_requestor
      @http_requestor ||= BmilzUtils::RandomUtils::HttpsHelper.new(:verify_cert=>false,:logger=>logger)
    end
    
    attr_accessor(:xsd_path)
    def xsd_path
      @xsd_path ||= "/doc/rbix_xsd/v5.5/rbis-api-5.5.xsd"
    end
    
    attr_accessor(:logger)
    def logger
      @logger
    end
    
    #Accepts a request object as xml (See XSD in doc folder for more details)
    #Returns a hash based on response object (See XSD in doc folder for more details)
    def do_request(mode, request_criteria)
      #make request to RBIS
      case mode
      when 'zipcode'
        request_url = base_url + "getCountiesForZip"
#        request_criteria = format_zip_request(params)
      when 'ihi_quote'
        request_url = base_url + "getPlans"
#        request_criteria = format_ihi_quote_request(params)
      when 'ihi_benefit'
        request_url = base_url + "getPlanBenefits"
#        request_criteria = format_ihi_benefit_request(params, params[:action] == "get_compare")
      when 'sg_quote'
        request_url = base_url + "getProducts"
#        request_criteria = format_sg_quote_request(params)
      when 'sg_benefit'
        request_url = base_url + "getProductBenefits"
#        request_criteria = format_sg_benefit_request(params, params[:action] == "get_compare")
      else 
        raise "RbisServiceV2::do_request does not support mode: #{mode}"
      end
      
      validate_xml(request_criteria)
      response = http_requestor.make_https_call(request_url, 'POST', request_criteria)
      validate_xml(response) 
      logger.debug request_criteria.to_s
      logger.debug response.to_s
      response
    end
    
    
    def validate_xml(request_xml)
      xsd = xsd = Nokogiri::XML::Schema(File.open(xsd_path))
      doc =  Nokogiri::XML(request_xml)
      errors = xsd.validate(doc)
      logger.debug "There was an error validating: \n #{request_xml}\n\n#{errors.inspect}" if errors.size > 0
      raise "There was an error validating: \n #{request_xml}\n\n#{errors.inspect}" if errors.size > 0
    end
  end
end