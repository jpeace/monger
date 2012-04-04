class Hash
  def mongo_id
    self['_id'] unless self['_id'].nil?
    self[:_id]
  end
end

class String
  def to_mongo_id
    BSON::ObjectId(self)
  end
end