require 'net/https'
require 'uri'

(1..1000).each do |n|
if ARGV.size > 0
  ARGV.each do|a|
    begin
    url='http://api.finder.healthcare.gov/v2.0/'
    
    #Load File
    file = File.new(a, "r")
    request_xml = file.read
    
    #make request object
    request = Net::HTTP::Post.new(url)
    request.add_field "Content-Type", "application/xml"
    request.body = request_xml
    
    #do request
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    ts = Time.now
    response = http.request(request)
    te = Time.now
    
    #log metrics to stdout
    puts "Completed #{a}  with response code #{response.code} in  #{te-ts} seconds."
    
    #save resonse to file for review
    fileout = File.new("test_#{a}.txt","w")
    fileout.puts "REQUEST\n\n"
    fileout.puts request_xml
    fileout.puts "\n\nRESPONSE\n\n"
    fileout.puts response.body
    fileout.close()
    rescue Exception => e
      puts "Error on #{a}"
      puts e.message
      e.backtrace.each {|bt| puts bt}
    end
  end
  
else
  puts "Please specify one or more XML files to test with!"
end
end
