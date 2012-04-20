class Class
  def build_symbol
    class_name = self.to_s.split('::').last
    symbol_name = class_name[0].downcase
    class_name[1..-1].chars.each do |c|
      if ('A'..'Z').include? c
        symbol_name << "_#{c.downcase}"
      else
        symbol_name << c
      end
    end

    symbol_name.to_sym
  end
end

class String
  def build_class_name
    class_name = build_javascript_name
    class_name[0] = class_name[0].upcase
    
    class_name
  end

  def build_javascript_name
    class_name = self
    separator = /_(\w)/
    class_name.scan(separator).count.times do
      pieces = class_name.partition(separator)
      class_name = pieces[0] + $~[1].upcase + pieces[2]
    end
    class_name
  end
end

class Symbol
  def build_class_name
    self.to_s.build_class_name
  end

  def build_javascript_name
    self.to_s.build_javascript_name
  end
end