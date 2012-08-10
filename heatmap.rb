require 'rubygems'
require 'json'
require 'httparty'
require 'sinatra'
require 'base64'
require 'openssl'
require 'uri'
require 'mongo'
require 'date'
require 'time'

class Festival
	include HTTParty
	def self.find_dat(string)
		base_url = "http://api.festivalslab.com"
		secret = "AsXhNDrxrTqi04cat0pEd4uQ0ftp4AbZ"
		query = "/events#{string}"
		signature = OpenSSL::HMAC.hexdigest('sha1', secret, query).to_s
		url_string = "#{base_url}#{query}&signature=#{signature}"
		puts url_string
		return JSON.parse(get(url_string, :headers => {'Accept' => 'application/json'}).body)
	end
	
	def self.days_data(date)
		services = JSON.parse(ENV['VCAP_SERVICES'])
		mongo_key = services.keys.select { |svc| svc =~ /mongo/i }.first
		mongo = services[mongo_key].first['credentials']
		mongo_conn = {:host => mongo['hostname'], :port => mongo['port'], :username => mongo['user'], :password => mongo['password']}
		
		@conn = Mongo::Connection.new(mongo['hostname'], mongo['port']).db(mongo['db']).authenticate(mongo['user'], mongo['password'])
		@db   = @conn['fringe']
		@coll = @db['individual']
		time = Time.now
		#puts @coll.find().to_a.to_json
		@coll.find({"start" => {"$gte" => Time.new(2011, time.month, time.day, 0, 0, 0), "$lte" => Time.new(2011, time.month, time.day, 0, 0, 0)}}).to_a.to_json
		#puts @coll.find(:start.gte => Time.new(2011, time.month, time.day, 0, 0, 0), :start.lte => Time.new(2011, time.month, time.day + 1, 0, 0, 0)).count
	end
end
get '/' do	
	# Festival.days_data(Time.new)
	# festival_data =  Festival.find_dat("?festival=demofringe&key=fbqjdpGIYZQc5F9m")
	# #puts festival_data
	# shows = {}
	# shows[:meta] = { :time => Time.now }
	# shows[:data] = []
	# festival_data.each do |show|
	# 	start = Time.local(Time.now.year, Time.now.month, Time.now.day, rand(23), rand(3) * 15)
	# 	finish = Time.local(Time.now.year, Time.now.month, Time.now.day, start.hour, (rand(3) * 15))
	# 	shows[:data] << {:capacity => show["performance_space"]["capacity"], :lat => show["venue"]["position"]["lat"], :lng => show["venue"]["position"]["lon"], :start => start, :end => finish}
	# end
	"#{params[:callback]}(#{Festival.days_data(Time.now)});"
end