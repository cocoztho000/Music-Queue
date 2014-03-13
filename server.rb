require 'sinatra'
require 'pathname'
require 'shellwords'
require 'thread'
require 'byebug'
require 'grooveshark'
require 'taglib'
require './player.rb'
require './song.rb'

set :bind => '0.0.0.0'

#client = Grooveshark::Client.new

queue = Array.new
player = Player.new(queue)
thread = Thread.new{player.playAll}

songlist = Array.new
mainoutput = String.new
thread2 = Thread.new{
	while(true)
		localsongs = nil
		localsongs = Hash.new
		songlist = Dir["./songs/*.mp3"] + Dir["./songs/*.m4a"]
		songlist.each do |songloc|
			pn = Pathname.new(songloc)
			TagLib::FileRef.open(pn.realpath.to_s) do |fileref|
				unless fileref.null?
					tag = fileref.tag
					song = Song.new(tag.title, tag.artist, tag.album, pn.realpath.to_s)
					localsongs[song.hash] = song
				end
			end
		end

		mainoutput = String.new
		localsongs.each do |hash,song|
			mainoutput << "<li><form name=\"#{hash}\" method=\"POST\" action=\"/queue\">
	    				<p>#{song.title}<button type=\"submit\" name=\"hash\" value=\"#{hash}\">Queue</button></p>
						</form></li>"
		end
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
		return "added"
	elsif(params["filename"])
		pn = Pathname.new("songs/" + params["filename"])
		title, artist, album = "", "", ""
		TagLib::FileRef.open(pn.realpath.to_s) do |fileref|
			unless fileref.null?
				tag = fileref.tag
				title = tag.title
				artist = tag.artist
				album = tag.album
			end
		end
		queue << Song.new(title, artist, album,(Dir.getwd + "/songs/" + params["filename"]).shellescape)
		return "added"
	elsif(params["hash"]]
		if(localsongs[params["hash"]])
			queue << localsongs[params["hash"].to_s]
			return "added"
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
