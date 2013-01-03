class Event
  attr_accessor :title, :artist
end

class Artist
  attr_accessor :name, :discography
end

class Disc
  attr_accessor :title, :tracks

  def initialize
    @tracks = []
  end

end

class Track
  attr_accessor :title, :length
end

class ProxyFactory

  def initialize(config)
    @config = config
  end

  def build(id, parent, prop)
    # if indirect property
    property = ProxyReference.new(id, parent, prop)
    # if collection w/ lazy-loading
    property = []

    # if collection w/ eager-on-reference
    property = ProxyCollection.new()
  end
end

class Proxy

  def initialize(id, parent, prop)
    @id = id
    @parent = parent
    @prop = prop
  end

  def method_missing(method, *args)
    entity = load_from_db(@id)
    @parent.send("#{prop}=", entity)
    args.empty? ? entity.send(method) : entity.send(method, args)
  end

end

class LazyLoadCollectionProxy

  def initialize(id, parent, index)
    @id = id
    @parent = parent
    @index = index
  end

  def method_missing(method, *args)
    entity = load_from_db(@id)
    @parent.send("[]=", [ @index, entity ])
    args.empty? ? entity.send(method) : entity.send(method.args)
  end

end

class CollectionProxy
  include Enumerable

  def initialize(ids, parent, prop)
    @ids = ids
    @parent = parent
    @prop = prop
  end

  def each

  end

end




class LazyLoadCollectionProxy

  def initialize(id, parent, index)
    @id = id
    @parent = parent
    @index = index
  end

  def method_missing(method, *args)
    entity = Track.new
    entity.title = "farts"
    @parent.send("[]=", [ @index, entity ])
    args.empty? ? entity.send(method) : entity.send(method.args)
  end

end


d = Disc.new
# eager on access loading - all tracks are hydrated upon referencing
d.tracks = ProxyCollection([ "123", "234", "345", "456" ], d, "tracklist")
# lazy loading - only track 0 is hydrated
a = []
[ "123", "234", "345", "456" ].each_with_index do |id, index|
  d.tracks << LazyLoadCollectionProxy.new(id, d.tracks, index)
end


