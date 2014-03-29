class Song
	attr_reader :title, :artist, :album, :playstring
	def initialize(title, artist, album, playstring)
		@title, @artist, @album, @playstring = title, artist, album, playstring
		if(@title == nil)
			@title = playstring
		end
	end

	def to_s
		return @title.to_s + @artist.to_s + @album.to_s + @playstring.to_s
	end
end