class Hash
  def monger_id
    return self['_id'] unless self['_id'].nil?
    self[:_id]
  end

  def monger_id=(value)
    self['_id'] = value
  end
end

class String
  def to_monger_id
    BSON::ObjectId(self)
  end
end

class Object
  def monger_id
    return self._id if self.respond_to? :_id
    nil
  end

  def monger_id=(value)
    self.instance_eval {
      @_id = value
      def _id
        @_id
      end
    }
  end
end