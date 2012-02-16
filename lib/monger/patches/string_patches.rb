class String
  def build_class_name
    class_name = self
    separator = /_(\w)/
    class_name.scan(separator).count.times do
      pieces = class_name.partition(separator)
      class_name = pieces[0] + $~[1].upcase + pieces[2]
    end
    class_name[0] = class_name[0].upcase
    
    class_name
  end
end