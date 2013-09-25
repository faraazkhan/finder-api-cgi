require 'rubygems'
require 'erb'
require 'nokogiri'
require_relative 'map_to_xsd.rb'
require_relative 'result_types.rb'
require_relative 'situation_types.rb'
require_relative 'audience_types.rb'
require_relative 'doi_states.rb'
require_relative 'rbis_service_v3'
require_relative 'bmilz_utils'

class FinderAPI
  
  include BmilzUtils::AcceptAttributeHash

  attr_accessor(:root_path)
  def root_path
    @root_path ||= File.dirname(caller[0].split(":")[0])
  end
  attr_accessor(:xsd)
  def xsd
    @xsd 
  end
  attr_accessor(:public_options_data)
  def public_options_data
    @public_options_data
  end  
  attr_accessor(:territory_data)
  def territory_data
    @territory_data
  end
  attr_accessor(:rbis)
  def rbis
    @rbis
  end
  attr_accessor(:logger)
  def logger
    @logger
  end
  
  def process_request(raw_xml_request)
    #clean the xml...
    cleaned_xml_request = raw_xml_request.gsub(/\>[\n\s]*</, "><")
    
    xml_request = parse_and_validate_request(cleaned_xml_request)

    log_requester(xml_request)
    
    #public or private?
    case xml_request.root.name
    when "PublicOptionsAPIRequest"
      xml_response = public_options(xml_request)
    when "PrivateOptionsAPIRequest"
      xml_response = private_options(xml_request)
    else
      raise InvalidRequestError.new(["Request type was not of Public or Private Options"])
    end
    
    validate_response(xml_response)

    ["200",{"Content-Type"=> "text/xml"},[xml_response]]

  rescue InvalidRequestError => e
    # we don't really care about invalid requests
    logger.debug "InvalidRequestError: \n    Request:"+cleaned_xml_request.to_str+"\n    Errors:"+e.getList.join("\n   ")
    ["400",{"Content-Type"=> "text/xml"},[build_xml_error_response("Invalid Request Exception",e.getList)]]
  rescue InvalidResponseError => e
    # TODO: log the actual error, send an "unknown exception error"?, this error should never occur in practice
    logger.error "InvalidResponseError: \n    Response:"+xml_response.to_str+"\n    Errors:"+e.getList.join("\n   ")
    ["500",{"Content-Type"=> "text/xml"},[build_xml_error_response("Exception",["An error was encountered while processing your request."])]]
  rescue Exception => e
    # we should write these out to a log
    logger.fatal "Unknown Exception: \n"+e.message+" \n   "+ e.backtrace.join("\n   ")
    ["500",{"Content-Type"=> "text/xml"},[build_xml_error_response("Exception",["An error was encountered while processing your request."])]]
  end

  private

  #*******************************************
  #*******************************************
  #*******  Private Option Methods ***********
  #*******************************************
  #*******************************************

  def private_options(raw_xml_request)
    
    #determin request type
    rbis_request_node_children = raw_xml_request.root.children
    rbis_request_node = raw_xml_request.root.children.first
    if rbis_request_node.name == "RequesterInfoData"
      rbis_request_node_children.each do |child|
        rbis_request_node = child
        if child.name != "RequesterInfoData"
          break
        end
      end
    end
    logger.debug rbis_request_node.name
    case rbis_request_node.name
      #build rbis_request
      when "CountiesForPostalCodeRequest"
        root_name = "ZipCodeValidationRequest"
        mode = "zipcode"
        response_name = "CountiesForPostalCodeResponse"
      when "PlansForIndividualOrFamilyRequest"
        root_name = "IndividualPlanQuoteRequest"
        mode = "ihi_quote"
        response_name = "PlansForIndividualOrFamilyResponse"
        
        ["//Enrollees", "//Location", "//PaginationInformation", "//SortOrder", "//Filter"].each do |xpath|
          if rbis_request_node.at_xpath(xpath)
            rbis_request_node.at_xpath(xpath).children.each do |node|
              node.default_namespace = "http://rbis.cms.org/api-types"
            end
          end
        end
        
      when "PlanDetailsForIndividualOrFamilyRequest"
        root_name = "IndividualPlanBenefitRequest"
        mode = "ihi_benefit"
        response_name = "PlanDetailsForIndividualOrFamilyResponse"
        
        ["//Enrollees", "//Location"].each do |xpath|
          if rbis_request_node.at_xpath(xpath)
            rbis_request_node.at_xpath(xpath).children.each do |node|
              node.default_namespace = "http://rbis.cms.org/api-types"
            end
          end
        end
        
      when "ProductsForSmallGroupRequest"
        root_name = "SmallGroupProductQuoteRequest"
        mode = "sg_quote"
        response_name = "ProductsForSmallGroupResponse"
        
        ["//Location", "//PaginationInformation", "//SortOrder", "//Filter"].each do |xpath|
          if rbis_request_node.at_xpath(xpath)
            rbis_request_node.at_xpath(xpath).children.each do |node|
              node.default_namespace = "http://rbis.cms.org/api-types"
            end
          end
        end
      when "ProductDetailsForSmallGroupRequest"
        root_name = "SmallGroupProductBenefitRequest"
        mode = "sg_benefit"
        response_name = "ProductDetailsForSmallGroupResponse"
    end

    formated_request = make_rbis_request_xml(root_name, rbis_request_node)
       
    #send rbis_request
    rbis_response = rbis.do_request(mode, formated_request)
 
    #pa
    rbis_response = Nokogiri::XML::Document.parse(rbis_response)
    logger.debug "RBISRESPONSE\n"+rbis_response.to_s
    #check for error
    if rbis_response.at_xpath("//ErrorMessage")
      raise InvalidResponseError, rbis_response.at_xpath("//ErrorMessage").content
    end
    
    #removing TotalWrittenPremium if its there
    rbis_response.css("TotalWrittenPremium").each do |node|
      node.remove
    end
    
    #build api_response
    builder = Nokogiri::XML::Builder.new do |xml_out|
      xml_out.PrivateOptionsAPIResponse {
        rbis_response.remove_namespaces!
        rbis_response.at_xpath("//ResponseHeader").remove
        rbis_response.at_xpath("//#{root_name}").remove
        xml_out << "<#{response_name}>" + rbis_response.root.children.to_s + "</#{response_name}>"
       }
     end
    
    #send response
    xml_as_string = builder.to_xml.to_s.gsub('nil="true"', 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:nil="true"')
    xml_as_string
  end
  
  def make_rbis_request_xml(root_name, content_node)
    logger.debug root_name
    logger.debug content_node
    rbis_request_xml = Nokogiri::XML::Document.new
    rbis_request_xml.root= Nokogiri::XML::Node.new(root_name, rbis_request_xml)
    rbis_request_xml.root.default_namespace = 'http://rbis.cms.org/api'
    rbis_request_xml.root.add_child content_node.children
    rbis_request_xml.to_xml
  end

  #*******************************************
  #*******************************************
  #*******  Public Option Methods ************
  #*******************************************
  #*******************************************
  def public_options(request_xml)
    #if request is valid, will contain one of state or territory abbreviation
    if request_xml.at_xpath('//StateAbbreviation')
      abbr = request_xml.at_xpath('//StateAbbreviation')
      audience_type, situation_type = decode_audience_and_situation_type(request_xml)
      return build_state_xml_response(request_xml,audience_type,situation_type,abbr.text)
    else
      abbr = request_xml.at_xpath('//TerritoryAbbreviation')
      return build_territory_xml_response(request_xml,abbr.text)
    end
  end
	
  def build_territory_xml_response(request_xml,abbr)
	  builder = Nokogiri::XML::Builder.new do |xml_out|
      xml_out.PublicOptionsAPIResponse {
        xml_out.PublicOptions {
          xml_out.PublicOption{
            dbterritory = territory_data.at_xpath("//TerritoryData[TerritoryAbbreviation = '#{abbr}']")
            xml_out << dbterritory.to_xml.to_str
          }
        }
       }
     end
    return builder.to_xml
	end
	
  def build_state_xml_response(request_xml,audience_type,situation_type,abbr)
    
    # age range
    if audience_type != "sr" && audience_type != "sbiz"
      cms_age_range = convert_finder_age_to_cms_age(request_xml.at_xpath('//AgeRange').text)
    else
      cms_age_range = "65+"
    end  

    # bools

    bool_pregnant = get_bool(request_xml,MapToXsd::XPATH_BOOL_PREGNANT)
    bool_dependents = get_bool(request_xml,MapToXsd::XPATH_BOOL_DEPENDENTS)
    bool_medical_condition = get_bool(request_xml,MapToXsd::XPATH_BOOL_MEDICAL_CONDITION)
    bool_disability = get_bool(request_xml,MapToXsd::XPATH_BOOL_DISABILITY)
    bool_special_need  = get_bool(request_xml,MapToXsd::XPATH_BOOL_SPECIAL_NEED)
    bool_ltc = get_bool(request_xml,MapToXsd::XPATH_BOOL_LTC)
    bool_no_afford = get_bool(request_xml,MapToXsd::XPATH_BOOL_NO_AFFORD)
    bool_cancer = get_bool(request_xml,MapToXsd::XPATH_BOOL_CANCER)
    bool_vet = get_bool(request_xml,MapToXsd::XPATH_BOOL_VET)
    bool_native = get_bool(request_xml,MapToXsd::XPATH_BOOL_NATIVE)
    
    logger.debug "bool_pregnant" + bool_pregnant.to_s
    logger.debug "bool_dependents" + bool_dependents.to_s 
    logger.debug "bool_medical_condition"+ bool_medical_condition.to_s
    logger.debug "bool_disability"+ bool_disability.to_s
    logger.debug "bool_special_need"+ bool_special_need.to_s
    logger.debug "bool_ltc"+ bool_ltc.to_s
    logger.debug "bool_no_afford"+ bool_no_afford.to_s
    logger.debug "bool_cancer"+ bool_cancer.to_s
    logger.debug "bool_vet"+ bool_vet.to_s
    logger.debug "bool_native"+ bool_native.to_s

    #db = @public_options_data.at_xpath("//State[StateAbbreviation = '#{abbr}']")

    dbstate = public_options_data.xpath("//State[StateAbbreviation = '#{abbr}']")
    chip_contact_data = dbstate.at_xpath('CHIPAndMedicaidData/CHIPContactInformation').clone
    mcd_contact_data = dbstate.at_xpath('CHIPAndMedicaidData/MedicaidContactInformation').clone

    benefit_groups =[]
    bene_group_ids_list = []
    disclaimer_group = []
      
    # get results
    results = AudienceTypes.results(audience_type,situation_type)
        
    #get Chip and MCD data
    if results.include? ResultTypes::MEDICAID or results.include? ResultTypes::CHIP
      
      elg_xpath = './/CHIPAndMedicaidData/EligibilityList/Eligibility['
      
      attr_to_bool_hash = {:Dependents => bool_dependents,
        :Disability => bool_disability,
        :LongTermCare => bool_ltc,
        :MedicalCondition => bool_medical_condition,
        :NoAfford => bool_no_afford,
        :Pregnant => bool_pregnant,
        :SpecialNeed => bool_special_need,
        :Cancer => bool_cancer}
      elg_xpath += (attr_to_bool_hash.map {|k,v| build_elg_bool_expath_item(k.to_s, v)}).join(" and ")
      elg_xpath += %^ and (@Age='#{cms_age_range}' or @Age='Any')^
      elg_xpath += ']'

      logger.debug elg_xpath
        
      elg_list = dbstate.xpath(elg_xpath)
      logger.debug "DBSTATE \n" +dbstate.to_s
      logger.debug "ELG LIST \n" +elg_list.to_s
      #get programs
      if results.include?(ResultTypes::MEDICAID) && mcd_contact_data
        mcd_programs = elg_list.xpath(".//Programs/Program[@Name = 'Medicaid']")
        
        if mcd_programs
          bene_group_ids_list += mcd_programs.xpath(".//BenefitGroups/BenefitGroup/@IDREF").map {|idref| "@ID='#{idref.value}'"}
        else
          results.delete(ResultTypes::MEDICAID)
        end
      end
      
      if results.include?(ResultTypes::CHIP) && chip_contact_data
        chip_programs = elg_list.xpath("Programs/Program[@Name = 'CHIP']")
        agerange= request_xml.xpath('.//AgeRange').text
        if chip_programs && agerange == "18 or Under"
          bene_group_ids_list += chip_programs.xpath("BenefitGroups/BenefitGroup/@IDREF").map {|idref| "@ID='#{idref.value}'"}
        else
          results.delete(ResultTypes::CHIP)
        end
      end
      
      if results.include?(ResultTypes::PARENTS)
        agerange= request_xml.xpath('.//AgeRange').text
        #puts agerange
        if agerange == "26-64" || agerange == "65 or older"
            results.delete(ResultTypes::PARENTS)
        end
      end
      
      #get benefit groups

      if bene_group_ids_list.size > 0
        bene_ids_query = bene_group_ids_list.uniq.join(" or ")
        benefit_groups =  dbstate.xpath("CHIPAndMedicaidData/BenefitGroups/BenefitGroup[#{bene_ids_query}]")
      end
      
      #get disclaimers
      disclaimer_ids = elg_list.xpath('@disclaimerIDREF').map {|idref| "@ID='#{idref.value}'"}.join(" or ")
      if disclaimer_ids != ""
        disclaimer_group = public_options_data.xpath("//CHIPAndMedicaidDisclaimers/Disclaimer[#{disclaimer_ids}]")
      end
    end
    
    # here we go
    builder = Nokogiri::XML::Builder.new do |xml_out|
      xml_out.PublicOptionsAPIResponse {

        xml_out.PublicOptions {
          results.push ResultTypes::VET if bool_vet
          results.push ResultTypes::CANCER if bool_cancer
          results.push ResultTypes::INDIAN if bool_native
          results.push ResultTypes::SAFETYNET unless (audience_type == AudienceTypes::SMALL_BUSINESS and situation_type == SituationTypes::Small_business::NEED)
          results.each do |result|
            xml_out.PublicOption {
              case result
              when ResultTypes::CHIP
                xml_out.ChipData {
                  chip_contact_data.name="ContactInformation"
                  xml_out << chip_contact_data.to_xml.to_s
                  xml_out.Programs {xml_out << chip_programs.to_xml.to_s } if chip_programs.size > 0
                }
              when ResultTypes::MEDICAID
                xml_out.MedicaidData {
                  mcd_contact_data.name="ContactInformation"
                  xml_out << mcd_contact_data.to_xml.to_s
                  xml_out.Programs {xml_out << mcd_programs.to_xml.to_s } if mcd_programs.size > 0
                }
              when ResultTypes::HIGH_RISK
                xml_out.HighriskData {
                    nil_or_xml = dbstate.at_xpath("StateHighRiskPlan")
                    xml_out << nil_or_xml.to_xml.to_s if nil_or_xml
                }
              when ResultTypes::IHI
                xml_out.IndividualAndFamilyPlanData {
                  xml_out << dbstate.at_xpath("IndividualMarketURL").to_xml.to_s
                }
              when ResultTypes::SMALL_BIZ_PLAN
                xml_out.SmallBusinessProductData {
                  xml_out << dbstate.at_xpath("GroupMarketURL").to_xml.to_s
                }
              else #everything else
                xml_out.PublicOptionData {
                  xml_out.PublicOptionName ResultTypes.results_info[result][0]
                  xml_out.PublicOptionDescription ResultTypes.results_info[result][2]
                  xml_out.PublicOptionURL ResultTypes.results_info[result][1]
                  xml_out.PublicOptionContent get_erb(audience_type,situation_type,result)
                }
              end
            }
          end
          
          #add benefit and disclaimer nodes if needed
          xml_out.CHIPAndMedicaidBenefitGroups{ xml_out << benefit_groups.to_xml.to_s}  if benefit_groups.size > 0
          xml_out.CHIPAndMedicaidDisclaimers{xml_out << disclaimer_group.to_xml.to_s} if disclaimer_group.size > 0
        }
        
        
      }
    end
    return builder.to_xml
  end
  

  def build_elg_bool_expath_item(attr_name,bool_val)
    %^(@#{attr_name} = 'Any' or @#{attr_name} = '#{bool_val ? 'Yes' : 'No'}')^
  end

  def decode_audience_and_situation_type(request_xml)

    audience_type = nil
    MapToXsd::AUDIENCE.each do |k,v|
      if audience_type.nil? and request_xml.xpath("//#{v}").size == 1
      audience_type = k
      end
    end
    raise "unable to process audience type" if audience_type.nil?

    situation_type = nil
    v_to_match = request_xml.xpath(MapToXsd::XPATH_SITUATION)[0].text.to_s
    MapToXsd::SITUATIONS[audience_type].each do |k,v|
      situation_type = k if v == v_to_match
    end
    raise "unable to process situation type" if situation_type.nil?

    return [audience_type,situation_type]

  end

  def get_bool(xml, xpath)
    results = xml.xpath(xpath)
    if results.size == 1 and results[0].text == "true"
    return true
    else
    return false
    end
  end

  def get_erb(audience_type,situation_type,result)
    main_path = File.join(root_path,"erb_templates","static_pages")
    f = nil

    f0 = File.join(main_path,"audience_specific",audience_type,"situation_specific",situation_type,"#{result}.html.erb")
    f1 = File.join(main_path,"audience_specific",audience_type,"#{result}.html.erb")
    f2 = File.join(main_path,"#{result}.html.erb")
    
    if File.exists? f0
    f = f0
    elsif File.exists? f1
    f = f1
    elsif File.exists? f2
    f = f2
    end

    if f
      begin
        return ERB.new(File.read(f)).result(binding)
      rescue Exception => e
        logger.error "could not process #{f}"
      return e.inspect
      end
    else
      logger.error "not found at: \n #{f1}\n#{f2}"
      return "no content found"

    end

  end

  def convert_finder_age_to_cms_age(age_string)
    if age_string == '18 or Under'
      return '0-18'
    elsif age_string == '19-25' or age_string == '26-64'
      return '19-64'
    elsif age_string == '65 or older'
      return '65+'
    else
      raise "bad age #{age_string}"
    end
  end
  
  #*******************************************
  #*******************************************
  #**** Helper Methods, Might Break Out  *****
  #*******************************************
  #*******************************************
  
  def parse_and_validate_request(x)
    xml = Nokogiri::XML(x)
    errors=[]
    xsd.validate(xml).each do |error|
      errors << error.message
    end
    if(errors.length > 0 )
      raise InvalidRequestError.new(errors)
    end
    return xml
  end

  def validate_response(x)
    xml = Nokogiri::XML(x)
    errors = []
    xsd.validate(xml).each do |error|
      errors << error.message
    end
    if(errors.length > 0 )
      raise InvalidResponseError.new(errors)
    end
  end

  class InvalidRequestError < StandardError
    def initialize(list)
      @list=list
    end
    def getList
      return @list
    end
  end

  class InvalidResponseError < StandardError
    def initialize(list)
      @list=list
    end
    def getList
      return @list
    end
  end

  def build_xml_error_response(type, error)
    builder = Nokogiri::XML::Builder.new do |xml_out|
      xml_out.PublicOptionsAPIResponse {
        xml_out.InvalidRequestReason type
        error.each do |err|
          xml_out.InvalidRequestDetails err
        end
      }
    end
    return builder.to_xml
  end
  
  def log_requester(request_xml)
    requester_name = request_xml.at_xpath("//OrganizationName")
    requester_email = request_xml.at_xpath("//ContactEmail")
    logger.debug ("Requester_from:#{requester_name.text} Email:#{requester_email.text}") if requester_name || requester_email
  end
end