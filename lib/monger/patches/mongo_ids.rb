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

class Object
  def mongo_id
    return self._id if self.respond_to? :_id
    nil
  end

  def mongo_id=(value)
    self.instance_eval {
      @_id = value
      def _id
        @_id
      end
    }
  end
end