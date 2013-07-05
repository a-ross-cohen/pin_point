require 'pin_point'
require 'rails'

module PinPoint
  
  class Railtie < Rails::Railtie
    rake_tasks do
      load "#{File.dirname(__FILE__)}/tasks/pin_point.rake"
    end
  end
  
end