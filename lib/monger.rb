require 'monger/patches'
require 'monger/config'
require 'monger/session'
require 'monger/mongo'
require 'monger/ember'
require 'monger/json'
require 'monger/version'

require 'time'
class TimeOfDay
  attr_accessor :hour, :minute, :second

  def initialize(hour, minute, second, period=nil)
    if period.nil?
      @hour = hour
    else
      case period
      when :am
        @hour = (hour == 12) ? 0 : hour
      when :pm
        @hour = hour + 12
      else
        raise ArgumentError
      end
    end

    @minute = minute
    @second = second
  end

  def to_12_hour
    period = (hour >= 12) ? 'PM' : 'AM'
    hour = @hour % 12
    hour = 12 if hour == 0
    minute = '%02d' % @minute
    second = '%02d' % @second
    if @second == 0
      "#{hour.to_i}:#{minute} #{period}"
    else
      "#{hour.to_i}:#{minute}:#{second} #{period}"
    end
  end

  def to_24_hour
    minute = '%02d' % @minute
    second = '%02d' % @second
    if @second == 0
      "#{@hour.to_i}:#{minute}"
    else
      "#{@hour.to_i}:#{minute}:#{second}"
    end
  end

  def self.now
    TimeOfDay.from_time(Time.now)
  end

  def self.from_time(time)
    TimeOfDay.new(time.hour, time.min, time.sec)
  end

  def self.from_string(s)
    TimeOfDay.from_time(Time.parse(s))
  end

  def ==(compare)
    @hour == compare.hour && @minute == compare.minute && @second == compare.second
  end
end

module Monger
  class << self
    def bootstrap(config_file)
      Configuration.from_file(config_file)
    end

    def create_session(config)
      Session.new(config)
    end
  end
end