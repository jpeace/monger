require 'monger/dsl/configuration_expression'

module Monger
  class Configuration
    attr_accessor :host, :port, :database, :modules, :maps

    def self.from_file(path)
      File.open(path, 'r') do |file|
        self.new(file.read)
      end
    end

    def initialize(script)
      @maps = {}
      dsl = Dsl::ConfigurationExpression.new(self)
      dsl.instance_eval(script)    
    end

    def build_class_of_type(type)
      klass = nil
      @modules.each do |mod|
        begin
          klass = mod.const_get(type.build_class_name)
          return klass.new
        rescue
          # Constant doesn't exist i.e. class is not in this module
        end
      end
      raise ArgumentError
    end
  end
end