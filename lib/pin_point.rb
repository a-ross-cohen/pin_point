require "pin_point/railtie" if defined?(Rails)
require "pin_point/version"
require "pin_point/ip_block"

module PinPoint
  
  class << self
    
    def ip ip
      IpBlock.for_ip ip
    end
    
  end
  
end
