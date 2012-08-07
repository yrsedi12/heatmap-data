require 'rubygems'
require 'json'
#require 'net/http'
require 'httparty'
require 'sinatra'
require 'base64'
require 'openssl'
require 'uri'

class Festival
	include HTTParty
	def self.find_dat(string)
		base_url = "http://api.festivalslab.com"
		secret = "AsXhNDrxrTqi04cat0pEd4uQ0ftp4AbZ"
		query = "/events#{string}"
		signature = OpenSSL::HMAC.hexdigest('sha1', secret, query).to_s
		url_string = "#{base_url}#{query}&signature=#{signature}"
		return JSON.parse(get(url_string, :headers => {'Accept' => 'application/json'}).body)
	end
end
get '/' do	
	festival_data =  Festival.find_dat("?festival=demofringe&key=fbqjdpGIYZQc5F9m")
	shows = []
	festival_data.each do |show|
		start = Time.local(Time.now.year, Time.now.month, Time.now.day, rand(23), rand(3) * 15)
		finish = Time.local(Time.now.year, Time.now.month, Time.now.day, start.hour, (rand(3) * 15))
		shows << {:capacity => show["performance_space"]["capacity"], :lat => show["venue"]["position"]["lat"], :lng => show["venue"]["position"]["lon"], :start => start, :end => finish}
	end
	shows.to_json
end