require 'rubygems'
require 'nokogiri'

def add_if_not_blank (xml_out, tag_name, value_to_use_if_not_blank)
	
	xml_out.method_missing(tag_name.to_s, value_to_use_if_not_blank) if value_to_use_if_not_blank.to_s.strip.size > 0
	
end

CURRENT_CGI='CTAC_XML_Files_15Feb2011'
CURRENT_TR='HealthCare_Gov_CMS_DATA_TestSub20110707a'

# files that CTAC maintains manually
contact_info_in = Nokogiri::XML(File.read(File.join(File.dirname(__FILE__),'data','contact_info.xml')))

# files the CGI provides
hrp_type_lookup = Nokogiri::XML(File.read(File.join(File.dirname(__FILE__),'data','dataloads',CURRENT_CGI,'XML_LookUp_HRPPlan_Types.xml')))
state_lookup = Nokogiri::XML(File.read(File.join(File.dirname(__FILE__),'data','dataloads',CURRENT_CGI,'XML_LookUp_States.xml')))
state_in = Nokogiri::XML(File.read(File.join(File.dirname(__FILE__),'data','dataloads',CURRENT_CGI,'XML_States.xml')))
hrp_xml_in = Nokogiri::XML(File.read(File.join(File.dirname(__FILE__),'data','dataloads',CURRENT_CGI,'XML_HRP.xml')))

# files the TR provives
tr_xml_in = Nokogiri::XML(File.read(File.join(File.dirname(__FILE__),'data','dataloads',CURRENT_TR,'healthcare_gov_cms_data.xml')))

# process the CGI lookup files
states_map = {}
state_lookup.xpath('//State').each do |s|
	states_map[s.at_xpath('State_Name').text] = s.at_xpath('State_Id').text
end
hrp_type_map = {}
hrp_type_lookup.xpath('//HRP_Pln_Type').each do |s|
	hrp_type_map[s.at_xpath('Plan_Type_Id').text] = s.at_xpath('HRP_PlnType_Name').text
end

all_state_abbrs = ['AL','AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY']

# put it all together
builder = Nokogiri::XML::Builder.new do |xml_out|
	xml_out.DBPublicOptions{
		xml_out.States{
			all_state_abbrs.each do |abbr|
				xml_out.State {
					
					# state abbr
					xml_out.StateAbbreviation abbr
				
					# market urls
					market_xml = state_in.at_xpath("//State[State_Name = '#{abbr}']/..")
					if market_xml
						xml_out.IndividualMarketURL market_xml.at_xpath("//State[State_Name = '#{abbr}']/Ind_Mkt_Url").text
						xml_out.GroupMarketURL market_xml.at_xpath("//State[State_Name = '#{abbr}']/Grp_Mkt_Url").text
					end
						
					# high risk
					h = hrp_xml_in.at_xpath("//LookUp[State_Id = '#{states_map[abbr]}']/..")
					if h
						if (hrp_type_map[h.at_xpath('LookUp/Plan_Type_Id').text]).to_s.downcase.include? 'state'
							xml_out.StateHighRiskPlan{
								xml_out.PlanName h.at_xpath('Brand_name').text
								pn = h.at_xpath('CS_TollFree').text
								pn = "1" + pn unless pn[0] == "1"
								xml_out.CustomerServicePhoneNumber pn 
								add_if_not_blank(xml_out, :CustomerServicePhoneNumberExtension, h.at_xpath('CS_TollFree_Ext').text)
								if h.at_xpath('State_Res_Req').text != "0"
									xml_out.StateResidencyRestriction {
										if h.at_xpath('Res_Length').text.to_s.downcase.include? 'no'
											xml_out.ResidencyLengthRequirmentIndicator false
										else
											xml_out.ResidencyLengthDescription h.at_xpath('Res_Length').text
										end
									}
								end
								add_if_not_blank(xml_out, :AgeLimitDescription, h.at_xpath('Age_Limit').text)
								xml_out.RestrictiveRiderIndicator 	h.at_xpath('Restrictive_Rider').text != "0"
								xml_out.ExcessivePremiumIndicator		h.at_xpath('Excess_Prem').text != "0"
								xml_out.HCTCEligibleIndicator 			h.at_xpath('HCTC_Eligible').text != "0"
								xml_out.HIPAAEligibleIndicator			h.at_xpath('HIPAA_Eligible').text != "0"
								xml_out.MedicareEligibleIndicator		h.at_xpath('Medicare_Eligible').text != "0"
								xml_out.DependantCoverageIndicator	h.at_xpath('Dependent_Cvrg').text != "0"
								add_if_not_blank(xml_out, :OtherEligibleDescription, h.at_xpath('Other_Eligibles').text)
								add_if_not_blank(xml_out, :OtherDescription, h.at_xpath('Desc_Other').text)
								add_if_not_blank(xml_out, :IncomeLimitSubsidy, h.at_xpath('Income_Limit_Subsidy').text)
								xml_out.RejectionLettersCount h.at_xpath('Number_Letters').text.to_i if h.at_xpath('Number_Letters').text.to_i > 0
								c_count = h.at_xpath('Cond_List').text.split(' ')[0].to_i
								xml_out.ConditionsCount c_count if c_count > 0
								add_if_not_blank(xml_out, :PlanOpenDescription, h.at_xpath('Open_To_New_Memb').text)
								add_if_not_blank(xml_out, :MainURL, h.at_xpath('Main_Url').text)
								add_if_not_blank(xml_out, :PremiumRatesURL, h.at_xpath('Links/Link/Premiums_Rates_Url').text)
								add_if_not_blank(xml_out, :CoverageBenefitsURL,h.at_xpath('Links/Link/Benefit_Cvrg_Url').text)
								add_if_not_blank(xml_out, :EligibilityURL, h.at_xpath('Links/Link/Eligibility_Url').text)
								add_if_not_blank(xml_out, :ConditionsListURL, h.at_xpath('Links/Link/Conditions_List_Url').text)
								add_if_not_blank(xml_out, :LowIncomeSubsidyUrl, h.at_xpath('Links/Link/Low_Income_Subsidy_Url').text)
							}
						else
							# right now there are no federal plans
							raise "bad plan type"
						end
					
					end
					
					# TR data (disclaimers are at very bottom)
					tr_state = tr_xml_in.at_xpath("//State[@StateAbbreviation='#{abbr}']")
					xml_out.CHIPAndMedicaidData{
					# chip / medicaid contact info
						xml_out.CHIPContactInformation{
							xml_out.BrandName tr_state.at_xpath('ChipBrandName').text
							xml_out.Description tr_state.at_xpath('ChipProgramDesc').text
							contact_info_in.at_xpath("//State[@abbr='#{abbr}']/CHIPContactInformation").elements.each{|x| xml_out << x.to_xml.to_s}
						}
						xml_out.MedicaidContactInformation{
							xml_out.BrandName tr_state.at_xpath('MedicaidBrandName').text
							xml_out.Description tr_state.at_xpath('MedicaidProgramDesc').text							
							contact_info_in.at_xpath("//State[@abbr='#{abbr}']/MedicaidContactInformation").elements.each{|x| xml_out << x.to_xml.to_s}
						}
						xml_out << tr_state.at_xpath('EligibilityList').to_xml.to_s
						xml_out << tr_state.at_xpath('BenefitGroups').to_xml.to_s
					}
					
				}
			end
		}
		
		# TR data disclaimers
		xml_out.CHIPAndMedicaidDisclaimers{
			 tr_xml_in.xpath('//Disclaimers/Disclaimer').each {|x| xml_out << x.to_xml.to_s}
		} 
	}
end

xml_to_write = builder.to_xml.to_s.gsub('<DBPublicOptions>',%^<DBPublicOptions xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="file:/Users/astowell/Documents/ews/finder_api/finder_api_v0.2.xsd">^)

File.open(File.join(File.dirname(__FILE__),'data','db','dbpublicoptions.xml'), 'w') {|f| f.write(xml_to_write) }



