class String
  def should_generate(codegen)
    should_eq IO.read("#{environment_root}/codegen/#{codegen}")
  end
end

describe Monger::Ember::Mapper do  
  it 'can build Ember object definitions' do
    subject.builld_object_def(:related).should_generate 'ember_object.js'
  end
  it 'can build domain' do
    subject.domain.should_generate 'domain.js'
  end
end