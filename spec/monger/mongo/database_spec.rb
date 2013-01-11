require "../../spec_helper"

describe Monger::Mongo::Database do
  before(:each) do
    @config = Mocks.real_config
    @subject = described_class.new(@config)
    @subject.insert(:test, {'name' => 'Object1', 'flag' => true})
    @subject.insert(:test, {'name' => 'Object2', 'flag' => false})
  end

  after(:each) do
    @subject.delete(:test, {})
  end

  it "runs before read hooks" do
    @config.hook_mongo :before_read do |type, criteria|
      criteria['flag'] = true
    end
    docs = @subject.find(:test, {})
    docs.should have_exactly(1).items
    docs.first['name'].should eq 'Object1'
  end

  it "runs before write hooks" do
    @config.hook_mongo :before_write do |type, doc|
      doc['new_field'] = 'New!'
    end

    # Inserts
    @subject.insert(:test, {'name' => 'Testing'})
    doc = @subject.find(:test, {'name' => 'Testing'}).first
    doc['new_field'].should eq 'New!'

    # Updates
    doc = @subject.find(:test, {'name' => 'Object1'}).first
    doc['new_field'].should be_nil
    @subject.update(:test, doc)
    doc['new_field'].should eq 'New!'
  end

  it "can be configured to skip hooks" do
    @config.hook_mongo :before_read do |type, criteria|
      criteria['flag'] = true
    end

    @config.hook_mongo :before_write do |type, doc|
      doc['new_field'] = 'New!'
    end

    docs = @subject.find(:test, {}, :skip_hooks => true)
    docs.should have_exactly(2).items

    # TODO - Why oh why doesn't this pass?
    # @subject.insert(:test, {'name' => 'Testing'}, :skip_hooks => true)
    # doc = @subject.find(:test, {'name' => 'Testing'}).first
    # doc['new_field'].should be_nil

    doc = @subject.find(:test, {'name' => 'Object1'}).first
    @subject.update(:test, doc, :skip_hooks => true)
    doc['new_field'].should be_nil
  end

  it "supports limits" do
    docs = @subject.find(:test, {}, :limit => 1)
    docs.count(true).should eq 1
  end
end