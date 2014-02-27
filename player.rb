require 'open4'
require 'thread'

class Player
	def initialize(queue)
		@queue = queue
	end

	def play(song)
		@pid, @stdin, @stdout, @stderr = Open4.popen4("mplayer -slave -quiet #{song}")
		until @stdout.gets.inspect =~ /Exiting/ do
		end
	end

	def playAll
		while(true)
			if(@queue[0] != nil)
				play(@queue[0])
				@queue.delete_at(0)
			else
				sleep 1
			end
		end
	end

	def pause
		@stdin.puts('pause 1')
	end

	def resume
		@stdin.puts('pause 0')
	end

	def next
		@stdin.puts('pt_step 1 1')
	end

	def kill
		Process.kill('TERM', @pid.to_i)
	end
end