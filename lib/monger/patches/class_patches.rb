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