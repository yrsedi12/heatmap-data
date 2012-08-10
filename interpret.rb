require 'rubygems'
require 'nokogiri'
require 'date'
require 'time'
require 'mongo'

@conn = Mongo::Connection.new
@db   = @conn['fringe']
@old = @db['performances']
@coll = @db['individual_performances']

@old.find.to_a.each do |event|
	puts event.to_hash
	event.to_hash["performances"].to_a.each do |performance|
		puts "Perf: #{performance}"
		performance_json = {}
		performance_json[:start] = performance.to_hash[:start].to_s
		performance_json[:end] = performance.to_hash[:end].to_s
		puts "Space: #{event['performance_space']['capacity']}"
		performance_json[:capacity] = event["performance_space"]["capacity"]
		puts "This: #{event.to_hash[:venue]}"
		if event.to_hash[:venue] != nil
			performance_json[:lat] = event.to_hash[:venue][:lat]
			performance_json[:lon] = event.to_hash[:venue][:lon]
		else
			performance_json[:lat] = 0
			performance_json[:lon] = 0
		end
		
		puts performance_json
		@coll.insert(performance_json)
	end
end
