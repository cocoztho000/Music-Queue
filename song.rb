class Song
	attr_reader :title, :artist, :album, :playstring
	def initialize(title, artist, album, playstring)
		@title, @artist, @album, @playstring = title, artist, album, playstring
		if(@title == nil)
			@title = playstring
		end
	end
end