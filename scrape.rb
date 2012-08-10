require 'rubygems'
require 'nokogiri'
require 'date'
require 'time'
require 'mongo'

@conn = Mongo::Connection.new
@db   = @conn['fringe']
@coll = @db['performances2']
@conn2 = Mongo::Connection.new
@db2 = @conn2['fringe']
@indiv = @db2['individual']

g = File.open('/Users/craigsnowden/Library/Containers/com.apple.mail/Data/Library/Mail Downloads/festivals_edinburgh/ticketing-performanceSpaces.xml')
performance_spaces = Nokogiri::XML(g)
g.close

h = File.open('/Users/craigsnowden/Library/Containers/com.apple.mail/Data/Library/Mail Downloads/festivals_edinburgh/ticketing-venues.xml')
venues = Nokogiri::XML(h)
h.close

Dir.foreach('/Users/craigsnowden/Library/Containers/com.apple.mail/Data/Library/Mail Downloads/festivals_edinburgh/performances') do |item|
	next if item == '.' or item == '..'
	puts 'wut'
	f = File.open("/Users/craigsnowden/Library/Containers/com.apple.mail/Data/Library/Mail Downloads/festivals_edinburgh/performances/#{item}")
	performances = Nokogiri::XML(f)
	f.close
	
	performances.css("PERFORMANCES Event").each do |event|
		event_json = {}
		event_json[:name] = event.at_css("EventName").content
		event_json[:performances] = []
		event_json[:performance_space] = {}
		event.css("Performance").each do |performance|
			performance_json = {}
			performance_json[:start] = Time.parse("#{performance.at_css('Date').content} #{performance.at_css('Time').content}")
			performance_json[:end] = performance_json[:start] + (performance.at_css("Duration").content.to_i * 60)
			event_json[:performance_space][:id] = performance.at_css("Layout Space")["id"]
			event_json[:performances] << performance_json
		end
		
		event_json[:performance_space][:capacity] = performance_spaces.at_css("SPACES Venue PerformanceSpace [id='#{event_json[:performance_space][:id]}'] Capacity").content
		event_json[:venue] = {}
		event_json[:venue][:id] = performance_spaces.at_css("SPACES Venue PerformanceSpace [id='#{event_json[:performance_space][:id]}']").parent[:id]
		
		event_json[:venue][:lat] = venues.at_css("VENUES Venue [id = '#{event_json[:venue][:id]}'] Latitude").content
		event_json[:venue][:lon] = venues.at_css("VENUES Venue [id = '#{event_json[:venue][:id]}'] Longitude").content
		@coll.insert(event_json)
		puts @coll.count
		
		event.css("Performance").each do |performance|
			individual_json = {}
			time = Time.parse("#{performance.at_css('Date').content} #{performance.at_css('Time').content}")
			individual_json[:start] = time.to_s
			individual_json[:end] = (time + (performance.at_css("Duration").content.to_i * 60)).to_s
			individual_json[:lat] = event_json[:venue][:lat]
			individual_json[:lon] = event_json[:venue][:lon]
			individual_json[:capacity] = event_json[:performance_space][:capacity]
			@indiv.insert(individual_json)
		end
	end
end

