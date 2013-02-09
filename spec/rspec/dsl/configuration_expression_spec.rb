describe Monger::Dsl::ConfigurationExpression do
  config = nil

  before(:each) do
    config = Monger::Configuration.new  
  end
  
  it 'can bring in external configurations' do
    config = double()
    expression = described_class.new(config)
    external_config = Monger::Configuration.new
    config.should_receive(:add_external_config).with(external_config)
    expression.import_configuration external_config
  end
end
