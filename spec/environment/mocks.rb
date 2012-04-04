require 'monger/config'

module Mocks
  class ConfigMock < Monger::Configuration
    def initialize
      @modules = [Domain::Auth, Domain]
    end
  end

  def config
    ConfigMock.new
  end

  def self.real_config
    Monger::Configuration.from_file("#{environment_root}/config/monger.rb")
  end
end