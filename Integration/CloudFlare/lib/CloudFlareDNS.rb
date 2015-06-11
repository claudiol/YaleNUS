require 'rest-client'
require 'json'
require 'singleton'
require 'yaml'
require 'CloudFlareConnection'
#load "CloudFlareConnection.rb"

# @abstract CloudFlareDNS
#  This class supports DNS requests to the CloudFlare DNS Service.
# It uses the CloudFlareConnection class to send GET, POST, DELETE HTTP Request to the CloudFlare REST API.
#
class CloudFlareDNS

  # @!method initialize
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


  # 
  # @!method add_cloudflare_record
  #
  # @param json_data - Data paylod for API.
  #
  # @return [Collection] Returns the YAML collection of configuration items. 
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

  # 
  # @!method list_cloudflare_dns_records
  # 
  # With this method you can list one or more records depending on the request.
  # The request payload to CloudFlare would look something like this:
  # type=A&name=example.com&content=127.0.0.1&page=1&per_page=20&order=type&direction=desc&match=all
  # 
  # @param request - Data request payload for API.
  #
  # @return [Collection] Returns the YAML collection of configuration items. 

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

  # 
  # @!method delete_cloudflare_dns_record
  # 
  # With this method you can delete a record depending on the request.
  # The request payload to CloudFlare would look something like this:
  # Example request looks like this:
  # c04e7e5094eb510a7241c30688fcbf0b
  # 
  # Basically we pass in the ID for the DNS record and append it to the REST API call.
  # Example: /client/v4/zones/:zone/dns_records/" + request
  #
  # @param request - Data request payload for API.
  #
  # @return [Collection] Returns the response from the REST API

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

  # 
  # @!method list_all_cloudflare_zones
  # 
  # @param none 
  #
  # @return [Collection] Zone records

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


  # 
  # @!method list_all_dns_records
  # The CloudFlare API returns up to 100 records per page.  We request the maximum number of records.
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
  # @return [Collection] DNS records

  def list_all_dns_records(page_number=1)
    # Set the location ... 
    @location = "/client/v4/zones/#{@zone}/dns_records?page=#{page_number}&per_page=100"

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
