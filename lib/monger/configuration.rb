module Monger
  class Configuration
    attr_accessor :host, :port, :database, :modules, :maps

    def self.from_file(path)
      File.open(path, 'r') do |file|
        self.new(file.read)
      end
    end

    def initialize(script)
      dsl = ConfigurationExpression.new(self)
      dsl.instance_eval(script)    
    end
  end

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

    def maps(*maps)
      @config.maps = maps
    end
  end
end