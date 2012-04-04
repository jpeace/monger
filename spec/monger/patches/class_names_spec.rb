class SingleClass
end

class FairlyLongClassName
end

module Namespace
  class NamespacedClass
  end
end

describe "Class patches" do
  it "can build a symbol from a single class" do
    SingleClass.build_symbol.should eq :single_class
  end

  it "will work with longer class names, too" do
    FairlyLongClassName.build_symbol.should eq :fairly_long_class_name
  end

  it "can build a symbol from a namespaced class" do
    Namespace::NamespacedClass.build_symbol.should eq :namespaced_class
  end
end

describe "Symbol patches" do
  it "can build a class name from a short symbol" do
    :short.build_class_name.should eq 'Short'
  end

  it "can build a class name from a long symbol" do
    :much_longer_symbol.build_class_name.should eq 'MuchLongerSymbol'
  end
end

describe "String patches" do
  it "can build a class name from a short string" do
    'short'.build_class_name.should eq 'Short'
  end

  it "can build a class name from a long string" do
    'much_longer_string'.build_class_name.should eq 'MuchLongerString'
  end
end