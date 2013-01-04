class LazyLoadCollectionProxy

  def initialize(db_mapper, entity_type, id, parent, index)
    @db_mapper = db_mapper
    @entity_type = entity_type
    @id = id
    @parent = parent
    @index = index
  end

  def method_missing(method, *args, &block)
    entity = @db_mapper.find_by_id(@entity_type, @id)
    @parent.send("[]=", [ @index, entity ])
    args.empty? ? entity.send(method) : entity.send(method, *args, &block)
  end

end