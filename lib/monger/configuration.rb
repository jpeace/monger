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
      dsl = Dsl::ConfigurationExpression.new(self)
      dsl.instance_eval(script)    
    end
  end
end