class Song
  attr_accessor :name, :artist, :album

  def initialize(name, artist, album)
    @name, @artist, @album = name, artist, album
  end
end

class Criteria
  def initialize(&block)
    @predicate = block
  end

  def Criteria.name(song_name)
    Criteria.new { |song| song_name == song.name }
  end

  def Criteria.artist(artist_name)
    Criteria.new { |song| artist_name == song.artist }
  end

  def Criteria.album(album_name)
    Criteria.new { |song| album_name == song.album }
  end

  def [](song)
    @predicate[song]
  end

  def &(criteria)
    Criteria.new { |song| self[song] and criteria[song] }
  end

  def |(criteria)
    Criteria.new { |song| self[song] or criteria[song] }
  end

  def !
    Criteria.new { |song| not self[song] }
  end
end

class Collection
  include Enumerable
  
  attr_accessor :songs

  def each(&block)
    @songs.each(&block)
  end

  def initialize(songs)
    @songs = songs
  end

  def Collection.parse(text)
    songs = text.split("\n").each_slice(4).map do |name, artist, album|
      Song.new name, artist, album
	  end
    new songs
  end

  def artists
    @songs.map(&:artist).uniq
  end

  def names
    @songs.map(&:name).uniq
  end

  def albums
    @songs.map(&:album).uniq
  end

  def filter(criteria)
    Collection.new @songs.select{ |song| criteria[song] }
  end

  def adjoin(sub_collection)
	  Collection.new(@songs + sub_collection.songs)
  end
end
