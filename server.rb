require 'sinatra'
require 'byebug'
require 'open4'
require 'grooveshark'
require './player.rb'

set :bind => '0.0.0.0'

client = Grooveshark::Client.new
queue = Array.new
player = Player.new(queue)
thread = Thread.new{player.playAll}

get '/' do
	"MediaServ"	
end

post '/queue' do
	#if(params["gid"])
	#	queue << Songs.find(params["gid"])
	#elsif (params["sid"])
	#	queue << Songs.find(params["sid"])
	#end
	song = client.search_songs(params["query"])[0]
	queue << client.get_song_url(song)
end

post '/do' do
	if(params["command"])
		command = params["command"].downcase
	else
		return "error"
	end
	
	if(command == "pause")
		player.pause
		return "done"
	elsif(command == "next")
		player.next
		return "done"
	end
	return "error"
end