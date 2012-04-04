class Hash
  def mongo_id
    self[:_id]
  end
end