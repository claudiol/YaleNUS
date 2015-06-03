#!/usr/bin/env ruby
#####################################################################################
# Copyright 2015 Lester Claudio <lester@redhat.com>
# Copyright 2015 Kenneth Evensen <kenneth.evensen@redhat.com>
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

class CloudFlareConnection
  include Singleton

  attr_reader :url

  def initialize
    @method = nil
    @url = nil
    @user = nil
    @password = nil
    @verifyssl = nil

  end

  def setup(tkn, email, zone, host, verifyssl=false)
    @tkn = tkn
    @email = email
    @zone = zone
    @verifyssl = verifyssl
    @url = host
  end

  def get(location, json_data)

    response = nil
    puts "#{location}"

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

  def post(location, json_data)

    response = nil
    puts "#{@url}#{location}"
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

  def put(location, json_data)

    response = nil
    puts "#{location}"

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
  			#:'x-auth-key' => "80ddf8458f30a996b7a6fdf3fa2c85d1ca03a",
			#:'x-auth-email' => "it.service.subscriber@yale-nus.edu.sg"}
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
      ).execute
    end

    if !response.nil?
      results = JSON.parse(response.to_str)
      return results
    end
  end

  def api_version
    @api_ver = "v4"
    return @api_ver
  end

  def delete(location, json_data)

    response = nil
    puts "#{location}"

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
      ).execute
    else
      response = RestClient::Request.new(
          :method => :delete,
          :url => @url+location,
          :user => @user,
          :verify_ssl => @verifyssl,
          :password => @password,
          :headers => { :accept => :json,
                        :content_type => :json,
  			:'x-auth-key' => @tkn,
			:'x-auth-email' => @email },
          :payload => json_data #JSON.generate(json_data)
      ).execute
    end

    if !response.nil?
      results = JSON.parse(response.to_str)
      return results
    end
  end

  def api_version
    @api_ver = "v4"
    return @api_ver
  end


end

