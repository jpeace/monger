class EagerCollectionProxy
  
  def initialize(db_mapper, entity_type, ids, parent, prop)
    @db_mapper = db_mapper
    @entity_type = entity_type
    @ids = ids
    @parent = parent
    @prop = prop
  end

  def method_missing(method, *args, &block)
    criteria = { :$or => [] }
    @ids.each do |id|
      criteria[:$or] << { :_id => id }
    end
    entity_list = @db_mapper.find(@entity_type, criteria)
    @parent.send("#{@prop}=", entity_list )
    args.empty? ? parent_property.send(method, &block) : parent_property.send(method, *args, &block)
  end

  def parent_property
    @parent.method(@prop).call
  end

end