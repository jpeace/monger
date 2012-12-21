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

      def js_namespace(namespace)
        @config.js_namespace = namespace
      end

      def debug(debug)
        @config.debug = debug
      end

      def modules(*modules)
        @config.add_modules(modules)
      end

      def import_configuration(config)
        @config.add_external_config(config)
      end

      def map(type)
        dsl = MappingExpression.new(@config, type)
        yield dsl
        @config.maps[type] = dsl.map
      end
    end
  end
end