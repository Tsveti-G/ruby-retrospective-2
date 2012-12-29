class Song
  attr_accessor :name, :artist, :album

  def initialize(name, artist, album)
    @name, @artist, @album = name, artist, album
  end
end

class Criteria
  def initialize(proc)
    @proc = proc
  end

  def Criteria.name(song_name)
    Criteria.new(lambda { |song| song_name == song.name })
  end

  def Criteria.artist(artist_name)
    Criteria.new(lambda { |song| artist_name == song.artist })
  end

  def Criteria.album(album_name)
    Criteria.new(lambda { |song| album_name == song.album })
  end

  def [](song)
    @proc[song]
  end

  def &(criteria)
    Criteria.new(lambda{ |song| self[song] && criteria[song] })
  end

  def |(criteria)
    Criteria.new(lambda{ |song| self[song] || criteria[song] })
  end

  def !
    Criteria.new(lambda{ |song| !self[song] })
  end
end

class Collection
  include Enumerable

  def each
    0.upto(@songs.size-1).each do |index|
      yield @songs[index]
    end
  end

  def initialize(songs)
    @songs = []
    @songs += songs
  end

  def Collection.parse(text)
    songs = []
    text.split("\n").each_slice(4) do |slice|
      songs << Song.new(slice[0], slice[1], slice[2])
    end
    Collection.new(songs)
  end

  def names
    @songs.map{ |song| song.name }.uniq
  end

  def artists
    @songs.map{ |song| song.artist }.uniq
  end

  def albums
    @songs.map{ |song| song.album }.uniq
  end

  def filter(criteria)
    Collection.new(@songs.select{ |song| criteria[song] })
  end

  def adjoin(sub_collection)
    sub_collection.each do |song|
      @songs << song
    end
    Collection.new(@songs.uniq)
  end
end
