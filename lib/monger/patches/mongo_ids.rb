class Hash
  def mongo_id
    return self['_id'] unless self['_id'].nil?
    self[:_id]
  end

  def mongo_id=(value)
    self['_id'] = value
  end
end

class String
  def to_mongo_id
    BSON::ObjectId(self)
  end
end