class ClassWithAccessors
  attr_accessor :prop1, :prop2, :prop3
  def initialize
    @prop1 = 0
    @prop2 = 0
  end
end

class ClassWithReaders
  attr_reader :prop1, :prop2, :prop3
  def initialize
    @prop1 = 0
    @prop3 = 0
  end
end

class ClassWithWriters
  attr_writer :prop1, :prop2, :prop3
  def initialize
    @prop2 = 0
    @prop3 = 0
  end
end

class MixedClass
  attr_accessor :prop1
  attr_reader :prop2
  attr_writer :prop3
  def initialize
    @prop1 = 0
    @prop2 = 0
  end
end

describe "Object property patches" do
  accessors = ClassWithAccessors.new
  readers = ClassWithReaders.new
  writers = ClassWithWriters.new
  mixed = MixedClass.new

  context "using getters" do
    it "iterates through initialized accessors" do
      accessors.getters.count.should eq 2
      accessors.getters.should include(:prop1, :prop2)
    end

    it "iterates through initialized readers" do
      readers.getters.count.should eq 2
      readers.getters.should include(:prop1, :prop3)
    end

    it "does not iterate through writers" do
      writers.getters.should be_empty
    end
  end

  context "using setters" do
    it "iterates through initialized accessors" do
      accessors.setters.size.should eq 2
      accessors.setters.should include(:prop1, :prop2)
    end

    it "does not iterate through readers" do
      readers.setters.should be_empty
    end

    it "iterates through initialized writers" do
      writers.setters.size.should eq 2
      writers.setters.should include(:prop2, :prop3)
    end
  end

  context "using all properties" do
    it "iterates through initialized accessors" do
      mixed.all_properties.count.should eq 1
      mixed.all_properties.should include(:prop1)
    end
  end

  context "getting and setting values" do
    it "gets property values" do
      accessors.prop1 = 7
      accessors.get_property(:prop1).should eq 7
    end

    it "sets property values" do
      accessors.set_property(:prop1, 7)
      accessors.prop1.should eq 7
    end
  end
end