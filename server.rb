require 'sinatra'
require 'pathname'
require 'shellwords'
require 'thread'
require 'byebug'
require 'grooveshark'
require './player.rb'

set :bind => '0.0.0.0'

client = Grooveshark::Client.new
queue = Array.new
player = Player.new(queue)
thread = Thread.new{player.playAll}

get '/' do
	files = Dir["./songs/*.mp3"] + Dir["./songs/*.m4a"]
	output = ""
	files.each do |x|
		pn = Pathname.new(x)
		namelength = pn.basename.to_s.length - pn.extname.to_s.length
		output << "<li><form name=\"#{pn.hash}\" method=\"POST\" action=\"/queue\">
    				<p>#{pn.basename.to_s[0..namelength - 1]}<button type=\"submit\" name=\"filename\" value=\"#{pn.basename}\">Queue</button></p>
					</form></li>"
	end
	output << "<form name=\"groovesharksearch\" method=\"POST\" action=\"/queue\">
    		<p>Search: <input type=\"text\" name=\"query\"> <input type=\"submit\" value=\"Submit\"></p>
		</form>"
	return output
end

post '/queue' do
	if(params["query"])
		song = client.search_songs(params["query"])[0]
		queue << client.get_song_url(song)
		return "added"
	elsif(params["filename"])
		queue << (Dir.getwd + "/songs/" + params["filename"]).shellescape
		return "added"
	else
		return "error"
	end
end

get '/showqueue' do
	return queue.to_s
end

post '/do' do
	if(params["command"])
		command = params["command"].downcase
	else
		return "error"
	end
	
	if(command == "pause") # Currently also resumes playing
		player.pause
		return "done"
	elsif(command == "next")
		player.next
		return "done"
	end
	return "error"
end