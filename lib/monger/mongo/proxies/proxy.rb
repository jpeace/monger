class Proxy

  def initialize(db_mapper, entity_type, id, parent, prop)
    @db_mapper = db_mapper
    @entity_type = entity_type
    @id = id
    @parent = parent
    @prop = prop
  end

  def method_missing(method, *args, &block)
    entity = @db_mapper.find_by_id(@entity_type, @id)
    @parent.send("#{prop}=", entity)
    args.empty? ? entity.send(method, &block) : entity.send(method, *args, &block)
  end

end