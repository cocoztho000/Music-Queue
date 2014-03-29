require 'sinatra'
require 'pathname'
require 'shellwords'
require 'thread'
require 'byebug'
require 'grooveshark'
require 'digest'
require 'taglib'
require './player.rb'
require './song.rb'

set :bind => '0.0.0.0'

client = Grooveshark::Client.new

queue = Array.new
player = Player.new(queue)
thread = Thread.new{player.playAll}

songlist = Array.new
mainoutput = String.new
localsongs = nil
sha256 = Digest::SHA256.new
thread2 = Thread.new{
	while(true)
		localsongs = Hash.new
		songlist = Dir["./songs/*.mp3"] + Dir["./songs/*.m4a"]
		songlist.each do |songloc|
			pn = Pathname.new(songloc)
			TagLib::FileRef.open(pn.realpath.to_s) do |fileref|
				unless fileref.null?
					tag = fileref.tag
					song = Song.new(tag.title, tag.artist, tag.album, pn.realpath.to_s)
					localsongs[sha256.hexdigest(song.to_s)] = song
				end
			end
		end

		mainoutput = String.new
		localsongs.each do |hash,song|
			mainoutput << "<li><form name=\"#{hash}\" method=\"POST\" action=\"/queue\">
	    				<p>#{song.title}<button type=\"submit\" name=\"hash\" value=\"#{hash}\">Queue</button></p>
						</form></li>"
		end

		mainoutput << "<form name=\"groovesharksearch\" method=\"POST\" action=\"/queue\">
    					<p>Search: <input type=\"text\" name=\"query\"> <input type=\"submit\" value=\"Submit\"></p>
						</form>"
		sleep 5
	end
}

get '/' do
	return mainoutput
end

post '/queue' do
	if(params["query"])
		song = client.search_songs(params["query"])[0]
		queue << Song.new(song.name, song.artist, song.album, client.get_song_url(song))
		redirect to('/')
	elsif(params["hash"] != nil)
		if(localsongs[params["hash"]])
			queue << localsongs[params["hash"].to_s]
			redirect to('/')
		else
			return "error: song does not exist"
		end
	else
		return "no valid params"
	end
end

get '/showqueue' do
	output = ""
	queue.each_with_index do |song, num|
		output << "<li>" + (num + 1).to_s + ". #{song.title}, #{song.artist}, #{song.album}</li>"
	end
	return output
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
