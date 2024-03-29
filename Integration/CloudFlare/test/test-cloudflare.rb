require 'rest-client'
require 'json'
require 'singleton'
require 'yaml'
gem 'CloudFlareDNS', '= 0.1'
require 'CloudFlareDNS'

### MAIN ROUTINE STARTS HERE ######
options={}
#options[:config_file] = 'cloudflare-config.yaml'
options[:tkn] = "80ddf8458f30a996b7a6fdf3fa2c85d1ca03a"
options[:email] = "it.service.subscriber@yale-nus.edu.sg" 
options[:zoneid] = "f64975b2ef75e68498f5cf1237a6c05b"
options[:apihost] = "api.cloudflare.com"

cfdns = CloudFlareDNS.new(options)

response = cfdns.list_all_cloudflare_zones

if response.nil?
   puts "No Zone records found"
else
   results = response['result']

   results.each do | record |
      puts "Zone Name: #{record['name']}  Status: #{record['status']} Zone id: #{record['id']}"
   end
end 

# Add a DNS Record to CloudFlare Data we will be adding
request_data = {}
request_data[:type] = "A"
request_data[:name] = "another.yale-nus.edu.sg"
request_data[:content] = "172.19.17.227"
request_data[:ttl] = "120"

json_data = JSON.generate(request_data)
puts "Adding DNS Record #{json_data} to CloudFlare Service ..."
response = cfdns.add_cloudflare_record(json_data)

# List DNS Records from CloudFlare
puts "Verify that DNS Record #{json_data} to CloudFlare Service ..."
request_data = "type=A&name=another.yale-nus.edu.sg&content=172.19.17.227&match=all"
response = cfdns.list_cloudflare_dns_record(request_data)

dns_record_id = nil
if response.nil?
   puts "No DNS records found"
else
   results = response['result']

   results.each do | record |
      puts "It Exists: #{record['name']}  #{record['content']} #{record['id']}"
      dns_record_id = record['id']
   end
end 

##
## Delete CloudFlare DNS Record
## 

if dns_record_id.nil?
   puts "No DNS record to delete"
else
   puts "Deleting DNS record: #{dns_record_id}"
   response = cfdns.delete_cloudflare_dns_record ( dns_record_id)
   puts response
end
