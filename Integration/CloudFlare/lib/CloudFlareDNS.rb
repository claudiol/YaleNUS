require 'rest-client'
require 'json'
require 'singleton'
require 'yaml'
require 'CloudFlareConnection'
#load "CloudFlareConnection.rb"


class CloudFlareDNS


  def initialize(options)

    if options.empty?
       raise "Please pass appropriate options for CloudFlareDNS class"
    end

    if options.has_key?(:config_file) 
      # Read values from Config File ...
      @config_name = options[:config_file] 
      # Read the YAML config file...
      @config = read_config(@config_name)
      @tkn = @config['credentials']['tkn']
      @email = @config['credentials']['email']
      @zone  = @config['credentials']['zoneid']
      # Set the Cloudflare host
      @host = @config['credentials']['apihost']
    else
      # We will get each option from the options hash
      if options.has_key?(:tkn)
         @tkn = options[:tkn]
      else
         raise "Need :tkn value for CloudFlare credentials"
      end
      if options.has_key?(:email)
        @email = options[:email]
      else
        raise "Need :email value for CloudFlare credentials"
      end
      if options.has_key?(:zoneid)
        @zone  = options[:zoneid]
      else
        raise "Need :zoneid value to execute to CloudFlare API "
      end
      if options.has_key?(:apihost)
        # Set the Cloudflare host
        @host = options[:apihost]
      else
        raise "Need :apihost value for CloudFlare credentials"
      end
    end
    # get the Cloudflare Instance - Singleton
    @client = CloudFlareConnection.instance
  end

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

    # get the Cloudflare Instance - Singleton
    @client = CloudFlareConnection.instance

    # Set the location ... 
    @location = "/client/v4/zones/#{@zone}/dns_records/"

    @client.setup(@tkn, @email, @host)

    response = nil

    begin
       response = @client.post(@location, json_data)
    rescue => ex
       puts ex.message
       puts ex.response
    end

    response
  end

  ###  {"id"=>"93adb6035b5abba148a31f2ffcf47c61", "type"=>"A", "name"=>"another.yale-nus.edu.sg", "content"=>"172.19.17.227", "proxiable"=>false, "proxied"=>false, "ttl"=>120, "locked"=>false, "zone_id"=>"f64975b2ef75e68498f5cf1237a6c05b", "zone_name"=>"yale-nus.edu.sg", "modified_on"=>"2015-05-28T18:19:28.339841Z", "created_on"=>"2015-05-28T18:19:28.339841Z", "meta"=>{"auto_added"=>false}
  #json_data = '{"type":"A","name":"another.yale-nus.edu.sg","content":"172.19.17.227","page"="1", "per_page"="20", "order"="type", "direction"="desc", "match"="all"}'
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

  def list_cloudflare_dns_record(request)

    # list records from Cloudflare 

    # get the Cloudflare Instance - Singleton
    @client = CloudFlareConnection.instance

    # Set the location ... 
    @location = "/client/v4/zones/#{@zone}/dns_records?" + request

    @client.setup(@tkn, @email, @host)

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

    # get the Cloudflare Instance - Singleton
    @client = CloudFlareConnection.instance

    # Set the location ... 
    @location = "/client/v4/zones/#{@zone}/dns_records/" + request

    @client.setup(@tkn, @email, @host)

    response = nil

    begin
       response = @client.delete(@location, nil)
    rescue => ex
       puts ex.message
       puts ex.backtrace
    end

    return response
  end

  ### List ALl CloudFlare Zones
  ###{"id":"f64975b2ef75e68498f5cf1237a6c05b","name":"yale-nus.edu.sg","status":"active","paused":false,"type":"full","development_mode":0,"name_servers":["fred.ns.cloudflare.com","pam.ns.cloudflare.com"],"original_name_servers":["NS1.WEBVIS.NET","NS2.WEBVIS.NET"],"original_registrar":"ICONZ-WEBVISIONS PTE LTD","original_dnshost":null,"modified_on":"2015-05-28T18:19:28.339841Z","created_on":"2013-08-30T16:15:27.503857Z","meta":{"step":4,"wildcard_proxiable":false,"custom_certificate_quota":0,"page_rule_quota":"3","phishing_detected":false,"multiple_railguns_allowed":false},"owner":{"type":"user","id":"7ff7e3b16eedf3d282bcb92a66af9db2","email":"it.service.subscriber@yale-nus.edu.sg"},"permissions":["#analytics:read","#billing:edit","#billing:read","#cache_purge:edit","#dns_records:edit","#dns_records:read","#organization:edit","#organization:read","#ssl:edit","#ssl:read","#waf:edit","#waf:read","#zone:edit","#zone:read","#zone_settings:edit","#zone_settings:read"],"plan":{"id":"0feeeeeeeeeeeeeeeeeeeeeeeeeeeeee","name":"Free Website","price":0,"currency":"USD","frequency":"","legacy_id":"free","is_subscribed":true,"can_subscribe":true,"externally_managed":false}}
  # Zone result data
  #{"id":"f64975b2ef75e68498f5cf1237a6c05b","name":"yale-nus.edu.sg","status":"active","paused":false,"type":"full","development_mode":0,"name_servers":["fred.ns.cloudflare.com","pam.ns.cloudflare.com"],"original_name_servers":["NS1.WEBVIS.NET","NS2.WEBVIS.NET"],"original_registrar":"ICONZ-WEBVISIONS PTE LTD","original_dnshost":null,"modified_on":"2015-05-28T18:19:28.339841Z","created_on":"2013-08-30T16:15:27.503857Z","meta":{"step":4,"wildcard_proxiable":false,"custom_certificate_quota":0,"page_rule_quota":"3","phishing_detected":false,"multiple_railguns_allowed":false},"owner":{"type":"user","id":"7ff7e3b16eedf3d282bcb92a66af9db2","email":"it.service.subscriber@yale-nus.edu.sg"},"permissions":["#analytics:read","#billing:edit","#billing:read","#cache_purge:edit","#dns_records:edit","#dns_records:read","#organization:edit","#organization:read","#ssl:edit","#ssl:read","#waf:edit","#waf:read","#zone:edit","#zone:read","#zone_settings:edit","#zone_settings:read"],"plan":{"id":"0feeeeeeeeeeeeeeeeeeeeeeeeeeeeee","name":"Free Website","price":0,"currency":"USD","frequency":"","legacy_id":"free","is_subscribed":true,"can_subscribe":true,"externally_managed":false}}

  def list_all_cloudflare_zones()
    # Set the location ... 
    @location = "/client/v4/zones"

    @client.setup(@tkn, @email, @host)

    response = nil

    begin
       response = @client.get(@location, nil)
    rescue => ex
       puts ex.message
       puts ex.backtrace
    end

    return response
  end
end
