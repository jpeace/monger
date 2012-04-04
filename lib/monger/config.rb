require 'monger/dsl/configuration_expression'

%w(map property).each do |dep|
  require "monger/config/#{dep}"
end

module Monger
  module Config
    module PropertyModes
      Direct = 0
      Reference = 1
      Collection = 2
    end
  end

  class Configuration
    attr_accessor :host, :port, :database, :modules
    attr_reader :maps

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

    def find_class(type)
      klass = nil
      @modules.each do |mod|
        begin
          klass = mod.const_get(type.build_class_name)
          return klass
        rescue
          # Constant doesn't exist i.e. class is not in this module
        end
      end
      raise ArgumentError
    end

    def build_object_of_type(type)
      find_class(type).new
    end  
  end
end