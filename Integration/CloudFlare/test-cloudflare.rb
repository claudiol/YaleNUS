require 'rest-client'
require 'json'
require 'singleton'
require 'yaml'
load "cloudflare.rb"


# 
# @!method read_config
#
# @param config_name [String] Configuration file name
#
# @return [Collection] Returns the YAML collection of configuration items. 
def read_config(config_name)
    begin
      return YAML.load_file(config_name)
    rescue => exception
      puts exception.message
    end
end


def add_cloudflare_record(json_data)

  # Add a record to Cloudflare 

  # Read the YAML config file...
  @config = read_config('cloudflare-config.yaml')
  tkn = @config['credentials']['tkn']
  email = @config['credentials']['email']
  zone  = @config['credentials']['zone-id']

  # get the Cloudflare Instance - Singleton
  @client = CloudFlareConnection.instance

  # Set the Cloudflare host
  @host = "api.cloudflare.com"
  # Set the location ... 
  @location = "/client/v4/zones/#{zone}/dns_records/"

  @client.setup(tkn, email, zone, @host)

  response = nil

  begin
     response = @client.post(@location, json_data)
  rescue => ex
     puts ex.message
     puts ex.response
  end

  response
end


def list_cloudflare_dns_record(request)

  # list records from Cloudflare 
  # Read the YAML config file...
  @config = read_config('cloudflare-config.yaml')
  tkn = @config['credentials']['tkn']
  email = @config['credentials']['email']
  zone  = @config['credentials']['zone-id']

  # get the Cloudflare Instance - Singleton
  @client = CloudFlareConnection.instance

  # Set the Cloudflare host
  @host = "api.cloudflare.com"
  # Set the location ... 
  @location = "/client/v4/zones/#{zone}/dns_records?" + request

  @client.setup(tkn, email, zone, @host)

  response = nil

  begin
     response = @client.get(@location, nil)
  rescue => ex
     puts ex.message
     puts ex.backtrace
  end

  return response
end

def delete_cloudflare_dns_record(request)

  # Read the YAML config file...
  @config = read_config('cloudflare-config.yaml')
  tkn = @config['credentials']['tkn']
  email = @config['credentials']['email']
  zone  = @config['credentials']['zone-id']

  # get the Cloudflare Instance - Singleton
  @client = CloudFlareConnection.instance

  # Set the Cloudflare host
  @host = "api.cloudflare.com"
  # Set the location ... 
  #@location = "/client/v4/zones/#{zone}/dns_records?" + request
  @location = "/client/v4/zones/#{zone}/dns_records/" + request

  @client.setup(tkn, email, zone, @host)

  response = nil

  begin
     response = @client.get(@location, nil)
  rescue => ex
     puts ex.message
     puts ex.backtrace
  end

  return response
end

# Zone result data
#{"id":"f64975b2ef75e68498f5cf1237a6c05b","name":"yale-nus.edu.sg","status":"active","paused":false,"type":"full","development_mode":0,"name_servers":["fred.ns.cloudflare.com","pam.ns.cloudflare.com"],"original_name_servers":["NS1.WEBVIS.NET","NS2.WEBVIS.NET"],"original_registrar":"ICONZ-WEBVISIONS PTE LTD","original_dnshost":null,"modified_on":"2015-05-28T18:19:28.339841Z","created_on":"2013-08-30T16:15:27.503857Z","meta":{"step":4,"wildcard_proxiable":false,"custom_certificate_quota":0,"page_rule_quota":"3","phishing_detected":false,"multiple_railguns_allowed":false},"owner":{"type":"user","id":"7ff7e3b16eedf3d282bcb92a66af9db2","email":"it.service.subscriber@yale-nus.edu.sg"},"permissions":["#analytics:read","#billing:edit","#billing:read","#cache_purge:edit","#dns_records:edit","#dns_records:read","#organization:edit","#organization:read","#ssl:edit","#ssl:read","#waf:edit","#waf:read","#zone:edit","#zone:read","#zone_settings:edit","#zone_settings:read"],"plan":{"id":"0feeeeeeeeeeeeeeeeeeeeeeeeeeeeee","name":"Free Website","price":0,"currency":"USD","frequency":"","legacy_id":"free","is_subscribed":true,"can_subscribe":true,"externally_managed":false}}

def list_all_cloudflare_zones()

  # Read the YAML config file...
  @config = read_config('cloudflare-config.yaml')
  tkn = @config['credentials']['tkn']
  email = @config['credentials']['email']
  zone  = @config['credentials']['zone-id']

  # get the Cloudflare Instance - Singleton
  @client = CloudFlareConnection.instance

  # Set the Cloudflare host
  @host = "api.cloudflare.com"
  # Set the location ... 
  @location = "/client/v4/zones"

  @client.setup(tkn, email, zone, @host)

  response = nil

  begin
     response = @client.get(@location, nil)
  rescue => ex
     puts ex.message
     puts ex.backtrace
  end

  return response
end

### MAIN ROUTINE STARTS HERE ######

### List ALl CloudFlare Zones
###{"id":"f64975b2ef75e68498f5cf1237a6c05b","name":"yale-nus.edu.sg","status":"active","paused":false,"type":"full","development_mode":0,"name_servers":["fred.ns.cloudflare.com","pam.ns.cloudflare.com"],"original_name_servers":["NS1.WEBVIS.NET","NS2.WEBVIS.NET"],"original_registrar":"ICONZ-WEBVISIONS PTE LTD","original_dnshost":null,"modified_on":"2015-05-28T18:19:28.339841Z","created_on":"2013-08-30T16:15:27.503857Z","meta":{"step":4,"wildcard_proxiable":false,"custom_certificate_quota":0,"page_rule_quota":"3","phishing_detected":false,"multiple_railguns_allowed":false},"owner":{"type":"user","id":"7ff7e3b16eedf3d282bcb92a66af9db2","email":"it.service.subscriber@yale-nus.edu.sg"},"permissions":["#analytics:read","#billing:edit","#billing:read","#cache_purge:edit","#dns_records:edit","#dns_records:read","#organization:edit","#organization:read","#ssl:edit","#ssl:read","#waf:edit","#waf:read","#zone:edit","#zone:read","#zone_settings:edit","#zone_settings:read"],"plan":{"id":"0feeeeeeeeeeeeeeeeeeeeeeeeeeeeee","name":"Free Website","price":0,"currency":"USD","frequency":"","legacy_id":"free","is_subscribed":true,"can_subscribe":true,"externally_managed":false}}

response = list_all_cloudflare_zones

if response.nil?
   puts "No Zone records found"
else
   results = response['result']

   results.each do | record |
      puts "Zone Name: #{record['name']}  Status: #{record['status']} Zone id: #{record['id']}"
   end
end 

# Add a DNS Record to CloudFlare Data we will be adding
json_data = '{"type":"A","name":"another.yale-nus.edu.sg","content":"172.19.17.227","ttl":120}'
puts "Adding DNS Record #{json_data} to CloudFlare Service ..."
response = add_cloudflare_record(json_data)

#https://api.cloudflare.com/client/v4/zones/9a7806061c88ada191ed06f989cc3dac/dns_records?type=A&name=example.com&content=127.0.0.1&page=1&per_page=20&order=type&direction=desc&match=all"\
#-H "X-Auth-Email: user@example.com"\
#-H "X-Auth-Key: c2547eb745079dac9320b638f5e225cf483cc5cfdda41"\
#-H "Content-Type: application/json"
#type=A
#name=example.com
#content=127.0.0.1
#page=1
#per_page=20
#order=type
#direction=desc&match=all"

# List DNS Records from CloudFlare
###  {"id"=>"93adb6035b5abba148a31f2ffcf47c61", "type"=>"A", "name"=>"another.yale-nus.edu.sg", "content"=>"172.19.17.227", "proxiable"=>false, "proxied"=>false, "ttl"=>120, "locked"=>false, "zone_id"=>"f64975b2ef75e68498f5cf1237a6c05b", "zone_name"=>"yale-nus.edu.sg", "modified_on"=>"2015-05-28T18:19:28.339841Z", "created_on"=>"2015-05-28T18:19:28.339841Z", "meta"=>{"auto_added"=>false}
#json_data = '{"type":"A","name":"another.yale-nus.edu.sg","content":"172.19.17.227","page"="1", "per_page"="20", "order"="type", "direction"="desc", "match"="all"}'
puts "Verify that DNS Record #{json_data} to CloudFlare Service ..."
request_data = "type=A&name=another.yale-nus.edu.sg&content=172.19.17.227&match=all"
response = list_cloudflare_dns_record(request_data)

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
   puts "Did not find a DNS record"
else
   puts "Deleting DNS record: #{dns_record_id}"
   response = delete_cloudflare_dns_record ( dns_record_id)
   puts response
end

