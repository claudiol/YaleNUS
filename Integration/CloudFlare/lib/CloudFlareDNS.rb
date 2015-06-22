require 'rest-client'
require 'json'
require 'singleton'
require 'yaml'
require 'CloudFlareConnection'
#load "CloudFlareConnection.rb"

#  CloudFlareDNS
#  This class supports DNS requests to the CloudFlare DNS Service.
#  It uses the CloudFlareConnection class to send GET, POST, DELETE HTTP Request to the CloudFlare REST API.
#
class CloudFlareDNS

  # @!method initialize
  # @version 0.2
  # Constructor
  #
  # @param options - <Hash> that contains the following options:
  #    -- :config_file - Name is the yaml config file
  #    or all required keys 
  #    -- :tkn - CloudFlare Authentication Token
  #    -- :email - CloudFlare Authentication Email
  #    -- :zoneid - CloudFlare zone id
  #    -- :apihost - CloudFlare REST API host
  # @return none
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
      if options.has_key?(:tkn) == false || 
	 options.has_key?(:email) == false ||
         options.has_key?(:zoneid) == false ||
         options.has_key?(:apihost) == false 
	raise "Please pass all required options :tkn, :email, :zoneid, :apihost"
      end
	 
      @tkn = options[:tkn]
      @email = options[:email]
      @zone  = options[:zoneid]
      # Set the Cloudflare host
      @host = options[:apihost]
    end

    # get the Cloudflare Instance - Singleton
    @client = CloudFlareConnection.instance
  end

  # 
  # @!method read_config
  # @version 0.2
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


  # 
  # @!method add_cloudflare_record
  # @version 0.2
  #
  # @param options - Options Hash with the following required parameters:
  #  :type 
  #  A 	 RFC 1035[1] 	IPv4 Address record 
  #  AAAA RFC 3596[2] 	IPv6 address record
  #  CNAME RFC 1035[1] 	Canonical name record
  #  LOC RFC 1876 	Location record
  #  MX 	RFC 1035[1] 	Mail exchange record
  #  NS 	RFC 1035[1] 	Name server record
  #  TXT RFC 1035[1] 	Text record
  #
  #  :name     
  #  FQDN for host e.g. "host.example.com"
  #
  #  :content
  #  IP address for host e.g. 192.168.0.1
  #
  #  Optional:
  #  :ttl 
  #  Time to live for DNS record. Value of 1 is 'automatic'
  #
  # @return [Hash] Returns the REST API Response from CloudFlareDNS
  def add_cloudflare_record(options)

    # Check required options
    if options.has_key?(:type) == false || options.has_key?(:name) == false || options.has_key?(:content) == false
	raise "Required options :type, :name and :content need to be present"
    end

    json_data = JSON.generate(options)

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
       raise ex
    end

    response
  end

  # 
  # @!method list_cloudflare_dns_records
  # @version 0.2
  # 
  #  With this method you can list one or more records depending on the request.
  #  The request payload to CloudFlare would look something like this:
  #  type=A&name=example.com&content=127.0.0.1&page=1&per_page=20&order=type&direction=desc&match=all
  # 
  # @param options - Options Hash with one of the following parameters:
  #
  #  :type 
  #  A 	 RFC 1035[1] 	IPv4 Address record 
  #  AAAA RFC 3596[2] 	IPv6 address record
  #  CNAME RFC 1035[1] 	Canonical name record
  #  LOC RFC 1876 	Location record
  #  MX 	RFC 1035[1] 	Mail exchange record
  #  NS 	RFC 1035[1] 	Name server record
  #  TXT RFC 1035[1] 	Text record
  #
  #  :name     
  #  FQDN for host e.g. "host.example.com"
  #
  #  :content
  #  IP address for host e.g. 192.168.0.1
  #
  #  :match
  #  all - Match all options (AND)
  #  any - Match any options (OR)
  #
  # @return [Hash] Returns response from CloudFlare REST API

  def list_cloudflare_dns_record(options)

    if options[:type].empty? == false
	request = "type=#{options[:type]}&"
    else
	request = "type=A&"
    end

    if options[:name].empty? == false
       request += "name=#{options[:name]}&"
    end

    if options[:content].empty? == false
       request += "content=#{options[:content]}&"
    end

    if options[:match].empty? == false
       request += "match=#{options[:match]}"
    else
	request += "match=all"
    end

    # list records from CloudFlare 

    # get the Cloudflare Instance - Singleton
    @client = CloudFlareConnection.instance

    # Set the location ... 
    @location = "/client/v4/zones/#{@zone}/dns_records?" + request

    @client.setup(@tkn, @email, @host)

    response = nil

    begin
       response = @client.get(@location, nil)
    rescue => ex
       raise ex
    end

    return response
  end

  # 
  # @!method delete_cloudflare_dns_record
  # @version 0.2
  # 
  #  With this method you can delete a record depending on the request.
  #  The request payload to CloudFlare would look something like this:
  #  Example request looks like this:
  #  c04e7e5094eb510a7241c30688fcbf0b
  # 
  #  Basically we pass in the ID for the DNS record and append it to the REST API call.
  #  Example: /client/v4/zones/:zone/dns_records/" + request
  #
  # @param dns_id - DNS record ID 
  #
  # @return [Hash] Returns the response from the REST API

  def delete_cloudflare_dns_record(dns_id)

    if dns_id.empty?
    	raise "dns_id cannot be empty"
    end

    # get the Cloudflare Instance - Singleton
    @client = CloudFlareConnection.instance

    # Set the location ... 
    @location = "/client/v4/zones/#{@zone}/dns_records/" + dns_id 

    @client.setup(@tkn, @email, @host)

    response = nil

    begin
       response = @client.delete(@location, nil)
    rescue => ex
       raise ex
    end

    return response
  end

  # 
  # @!method list_all_cloudflare_zones
  # @version 0.2
  # 
  # @param none 
  #
  # @return [Hash] Zone records will be in response['result']

  def list_all_cloudflare_zones()
    # Set the location ... 
    @location = "/client/v4/zones"

    @client.setup(@tkn, @email, @host)

    response = nil

    begin
       response = @client.get(@location, nil)
    rescue => ex
       raise ex
    end

    return response
  end


  # 
  # @!method list_all_dns_records
  # @version 0.2
  #  The CloudFlare API returns up to 100 records per page.  We request the maximum number of records.
  # 
  #
  #  #Lets use the CloudFlareDNS to get DNS records ...     
  #  cfdns = CloudFlareDNS.new(options)
  #
  #  page_number = 1
  #  response = cfdns.list_all_dns_records(page_number)
  #
  #  #Check the reponse ... page through each if necessary
  #  unless response.nil?
  #    if response["success"]
  #      puts "Success" if @debug
  #      records = response['result']
  #      result_info = response['result_info']
  #      total_count = result_info['total_count']
  #      count = result_info['count']
  #      #
  #      # Check to see if there are more than one page of results ...
  #      # CloudFlareDNS only gives you a maximum of 100 records per page.
  #      # The records variable will hold all the records from CloudFlare. Just return it to the caller 
  #      # iterate through the records.
  #      while count*page_number < total_count
  #        page_number += 1
  #        response = cfdns.list_all_dns_records(page_number)
  #        records += response['result']
  #      end
  #      puts "Total Records: #{total_count} Count: #{count}" if @debug
  #    end
  #  end
  #
  # @param page_number - Which page to return DNS Records data for 
  #
  # @return [Hash] DNS records will be in response['result']

  def list_all_dns_records(page_number=1)
    # Set the location ... 
    @location = "/client/v4/zones/#{@zone}/dns_records?page=#{page_number}&per_page=100"

    @client.setup(@tkn, @email, @host)

    response = nil

    begin
       response = @client.get(@location, nil)
    rescue => ex
       raise ex
    end

    return response
  end
end
