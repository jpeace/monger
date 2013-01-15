describe Monger::Dsl::ConfigurationExpression do
  config = nil

  before(:each) do
    config = Monger::Configuration.new  
  end

  it 'can read external configuration files' do
    config = double()
    expression = described_class.new(config)
    config.should_receive(:parse_external_config_file).with('/path/to/file')
    expression.import_configuration '/path/to/file'
  end
  
  it 'can bring in external configurations' do
    config = double()
    expression = described_class.new(config)
    external_config = Monger::Configuration.new
    config.should_receive(:add_external_config).with(external_config)
    expression.import_configuration external_config
  end
end
