module Mocks
  def config
    c = double("Configuration")
    c.stub(:modules) {[Domain::Auth, Domain]}
    c
  end
end