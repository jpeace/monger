class Object
  def getters
    generate_properties(/\A(\w+)\Z/, 0)
  end

  def setters
    generate_properties(/\A(\w+)=\Z/, 1)
  end

  def all_properties
    getters & setters
  end

  def get_property(prop)
    self.method(prop).call
  end

  def set_property(prop, value)
    setter = "#{prop}=".to_sym
    self.method(setter).call(value)
  end
  
  private

  def generate_properties(reg_exp, arity)
    ret = []
    self.methods.each do |m|
      match = reg_exp.match(m)
      if match && self.method(m).arity == arity
        prop_name = match[1]
        ret << prop_name.to_sym if self.instance_variable_defined?("@#{prop_name}")
      end
    end
    ret
  end
end