require 'rubygems'
require 'nokogiri'
require 'csv'

builder = Nokogiri::XML::Builder.new do |xml_out|
	xml_out.States{
		# "ABBREVIATION";"MCD_URL";"CHIP_URL";"MCD_PHONE";"CHIP_PHONE";"CHIP_NAME";"MCD_NAME";"CHIP_DESC";"MCD_DESC"
		CSV.read(File.join(File.dirname(__FILE__),'med_chip_contact_info.csv')).each do |r|
			xml_out.State(:abbr => r[0]) {
				xml_out.CHIPContactInformation {
					xml_out.BrandName r[5]
					xml_out.Description r[7]
					xml_out.PhoneNumber r[4]
					xml_out.URL r[2]
				}
				xml_out.MedicaidContactInformation {
					xml_out.BrandName r[6]
					xml_out.Description r[8]
					xml_out.PhoneNumber r[3]
					xml_out.URL  r[1]
				}
			}
		end
	}
end


puts builder.to_xml