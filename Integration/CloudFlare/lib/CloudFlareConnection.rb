#!/usr/bin/env ruby
#####################################################################################
# @author Copyright 2015 Lester Claudio <lester@redhat.com>
# @author Copyright 2015 Kenneth Evensen <kenneth.evensen@redhat.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
######################################################################################
#
# Contact Info: <kenneth.evensen@redhat.com> and <lester@redhat.com>
#
######################################################################################

######################################################################################
## 2.1 - CloudFlare API Basic Parameters
## Every GET/POST request must include at the following basic parameter(s):
## 
## "tkn"
## This is the API key made available on your Account page.
## 
## "email"
## The e-mail address associated with the API key.
## 
## "a"
## To define which request is being made, the client should POST an "a" parameter. The "a" specifies which action you'd like to perform. Specific actions are described in Section 3 below.
######################################################################################

require 'rest-client'
require 'json'
require 'singleton'

# @abstract CloudFlareConnection
#  Singleton connection class to support CloudFlare DNS service calls.
# This class could be used for any generic REST API service calls.
#
class CloudFlareConnection
  include Singleton

  attr_reader :url

  # 
  # @!method initialize
  #
  # Constructor
  #
  # @param none.
  # @return none
  def initialize
    @method = nil
    @url = nil
    @user = nil
    @password = nil
    @verifyssl = nil

  end

  # 
  # @!method set_up
  #
  # Sets up the internal class instance variables. 
  #
  # @param       tkn - Authentication token for CloudFlare 
  # @param     email - Authentication email attached to the CloudFlare account
  # @param      host - CloudFlare connection host - e.g. api.cloudflare.com
  # @param verifyssl - Whether or not to use SSL (true/false)
  #
  # @return none
  #
  def setup(tkn, email, host, verifyssl=false)
    @tkn = tkn
    @email = email
    @verifyssl = verifyssl
    @url = host
  end

  # @!method get
  # Handles the GET requests
  # @param location - Location for REST API e.g. /zones/:zone_identifier/dns_records
  # @param json_data - Data paylod for API.
  #
  # @return results - Response from CloudFlare REST API
  #
  def get(location, json_data)

    response = nil

    if json_data.nil?
      response = RestClient::Request.new(
          :method => :get,
          :url => @url+location,
          :user => @user,
          :password => @password,
          :verify_ssl => @verifyssl,
          :headers => { :accept => :json,
                        :content_type => :json,
  			:'x-auth-key' => @tkn,
			:'x-auth-email' => @email }
      ).execute
    else
      response = RestClient::Request.new(
          :method => :get,
          :url => @url+location,
          :user => @user,
          :password => @password,
          :verify_ssl => @verifyssl,
          :headers => { :accept => :json,
                        :content_type => :json,
  			:'x-auth-key' => @tkn,
			:'x-auth-email' => @email },
          :payload => json_data # JSON.generate(json_data)
      ).execute { |response, request, result, &block|
       	if [301, 302, 307].include? response.code
         	response.follow_redirection(request, result, &block)
       	else
         	response.return!(request, result, &block)
        end
      }
    end

    if !response.nil?
      results = JSON.parse(response.to_str)
      return results
    end
  end

  # @!method post
  # Handles the POST requests
  # @param location - Location for REST API e.g. /zones/:zone_identifier/dns_records
  # @param json_data - Data paylod for API.
  #
  # @return results - Response from CloudFlare REST API
  #
  def post(location, json_data)

    response = nil
    if json_data.nil?
      response = RestClient::Request.new(
          :method => :post,
          :url => @url+location,
          :user => @user,
          :verify_ssl => @verifyssl,
          :password => @password,
          :headers => { :accept => :json,
                        :content_type => :json,
  			:'x-auth-key' => @tkn,
			:'x-auth-email' => @email }
      ).execute
    else
      response = RestClient::Request.new(
          :method => :post,
          :url => @url+location,
          :user => @user,
          :verify_ssl => @verifyssl,
          :password => @password,
          :headers => { :accept => :json,
                        :content_type => :json, 
  			:'x-auth-key' => @tkn,
			:'x-auth-email' => @email },
          :payload => json_data
      ).execute { |response, request, result, &block|
       	if [301, 302, 307].include? response.code
         	response.follow_redirection(request, result, &block)
       	else
         	response.return!(request, result, &block)
        end
      }
    end

    if !response.nil?
      results = JSON.parse(response.to_str)
      return results
    end
  end

  # @!method put
  # Handles the PUT requests 
  # @param location - Location for REST API e.g. /zones/:zone_identifier/dns_records 
  # @param json_data - Data paylod for API.
  #
  # @return results - Response from CloudFlare REST API
  #
  def put(location, json_data)

    response = nil

    if json_data.nil?
      response = RestClient::Request.new(
          :method => :put,
          :url => @url+location,
          :user => @user,
          :verify_ssl => @verifyssl,
          :password => @password,
          :headers => { :accept => :json,
                        :content_type => :json,
  			:'x-auth-key' => @tkn,
			:'x-auth-email' => @email }
      ).execute
    else
      response = RestClient::Request.new(
          :method => :put,
          :url => @url+location,
          :user => @user,
          :verify_ssl => @verifyssl,
          :password => @password,
          :headers => { :accept => :json,
                        :content_type => :json,
  			:'x-auth-key' => @tkn,
			:'x-auth-email' => @email },
          :payload => json_data #JSON.generate(json_data)
      ).execute { |response, request, result, &block|
       	if [301, 302, 307].include? response.code
         	response.follow_redirection(request, result, &block)
       	else
         	response.return!(request, result, &block)
        end
      }
    end

    if !response.nil?
      results = JSON.parse(response.to_str)
      return results
    end
  end

  # @!method delete
  # Handles the DELETE requests
  # @param location - Location for REST API e.g. /zones/:zone_identifier/dns_records/:identifier
  # @param json_data - Data paylod for API.
  #
  # @return results - Response from CloudFlare REST API
  #
  def delete(location, json_data)

    response = nil

    if json_data.nil?
      response = RestClient::Request.new(
          :method => :delete,
          :url => @url+location,
          :user => @user,
          :verify_ssl => @verifyssl,
          :password => @password,
          :headers => { :accept => :json,
                        :content_type => :json,
  			:'x-auth-key' => @tkn,
			:'x-auth-email' => @email }
      ).execute { |response, request, result, &block|
       	if [301, 302, 307].include? response.code
         	response.follow_redirection(request, result, &block)
       	else
         	response.return!(request, result, &block)
        end
      }
    else
      response = RestClient::Request.new(
          :method => :delete,
          :url => @url+location,
          :user => @user,
          :password => @password,
          :verify_ssl => @verifyssl,
          :headers => { :accept => :json,
                        :content_type => :json,
  			:'x-auth-key' => @tkn,
			:'x-auth-email' => @email },
          :payload => json_data 
      ).execute { |response, request, result, &block|
       	if [301, 302, 307].include? response.code
         	response.follow_redirection(request, result, &block)
       	else
         	response.return!(request, result, &block)
        end
      }
    end

    if !response.nil?
      results = JSON.parse(response.to_str)
      return results
    end
  end

  # @!method api_version
  # Returns the CloudFlareConnection Version
  def api_version
    @api_ver = "v4"
    return @api_ver
  end
end

