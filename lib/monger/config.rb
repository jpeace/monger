require 'monger/dsl/configuration_expression'

%w(map property).each do |dep|
  require "monger/config/#{dep}"
end

module Monger
  class Configuration
    attr_accessor :host, :port, :database, :js_namespace, :modules, :debug
    attr_reader :mongo_hooks, :maps

    def self.from_file(path)
      File.open(path, 'r') do |file|
        self.new(file.read)
      end
    end

    def initialize(script='')
      @mongo_hooks = {
        :before_read => [],
        :before_write => []
      }
      @maps = {}
      dsl = Dsl::ConfigurationExpression.new(self)
      dsl.instance_eval(script)    
    end

    def verbose?
      @debug
    end

    def hook_mongo(hook, &block)
      raise ArgumentError unless @mongo_hooks.keys.include? hook
      @mongo_hooks[hook] << block
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