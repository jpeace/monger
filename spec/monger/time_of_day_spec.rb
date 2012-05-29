describe TimeOfDay do
  it "works with 24 hour times" do
    time = described_class.new(5, 30, 45)
    time.hour.should eq 5
    time.minute.should eq 30
    time.second.should eq 45
  end

  it "works with 12 hour times" do
    time = described_class.new(5, 30, 45, :am)
    time.hour.should eq 5
    time.minute.should eq 30
    time.second.should eq 45

    time = described_class.new(5, 30, 45, :pm)
    time.hour.should eq 17
    time.minute.should eq 30
    time.second.should eq 45
  end

  it "works with midnight" do
    time = described_class.new(12, 0, 0, :am)
    time.hour.should eq 0
    time.minute.should eq 0
    time.second.should eq 0
  end

  it "displays time in 12 hour format" do
    time = described_class.new(5, 30, 45, :pm)
    time.to_12_hour.should eq "5:30:45 PM"
  end

  it "displays time in 24 hour format" do
    time = described_class.new(5, 30, 45, :pm)
    time.to_24_hour.should eq "17:30:45"
  end

  it "displays a short time when seconds are 0" do
    time = described_class.new(5, 30, 0, :pm)
    time.to_12_hour.should eq "5:30 PM"
    time.to_24_hour.should eq "17:30"
  end

  it "pads minutes and seconds" do
    time = described_class.new(5,5,5,:pm)
    time.to_12_hour.should eq "5:05:05 PM"
    time.to_24_hour.should eq "17:05:05"
  end

  it "displays midnight" do
    time = described_class.new(12, 0, 0, :am)
    time.to_12_hour.should eq "12:00 AM"
    time = described_class.new(0, 0, 0)
    time.to_12_hour.should eq "12:00 AM"
  end

  it "displays correctly when given floats" do
    time = described_class.new(9.0, 5.0, 25.0)
    time.to_12_hour.should eq "9:05:25 AM"
    time.to_24_hour.should eq "9:05:25"
  end

  it "can build a time of day from a ruby time object" do
    ruby_time = Time.new(2012, 5, 16, 15, 30, 45)
    time = described_class.from_time(ruby_time)
    time.to_12_hour.should eq "3:30:45 PM"
  end

  it "can build a time of day from strings" do
    time = described_class.from_string('9:30 pm')
    time.to_12_hour.should eq "9:30 PM"

    time = described_class.from_string('4:35:20 AM')
    time.to_12_hour.should eq "4:35:20 AM"
  end

  it "properly evaluates equality" do
    time1 = described_class.new(9, 30, 45, :pm)
    time2 = described_class.new(9, 30, 45, :pm)
    time1.should eq time2
  end
end