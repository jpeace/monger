require 'monger/dsl/mapping_expression'

module Monger
  module Dsl
    class ConfigurationExpression
      def initialize(config)
        @config = config
      end

      def host(host)
        @config.host = host
      end

      def database(database)
        @config.database = database
      end

      def port(port)
        @config.port = port
      end

      def modules(*modules)
        @config.modules = modules
      end

      def map(type)
        dsl = MappingExpression.new(@config, type)
        yield dsl
        @config.maps[type] = dsl.map
      end
    end
  end
end