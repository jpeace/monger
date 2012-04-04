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
end