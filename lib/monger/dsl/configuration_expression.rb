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

      def import_configuration(config_or_path)
        if config_or_path.is_a? String
          @config.parse_external_config_file(config_or_path)
        elsif config_or_path.is_a? ::Monger::Configuration
          @config.add_external_config(config_or_path)
        else
          raise ArgumentError, "Argument #{config.inspect} given for import_configuration not a string or a module"
        end
      end

      def map(type)
        dsl = MappingExpression.new(@config, type)
        yield dsl
        @config.maps[type] = dsl.map
      end
    end
  end
end