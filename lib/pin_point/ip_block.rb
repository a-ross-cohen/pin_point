require 'mongoid'

module PinPoint
  
  class IpBlock
    
    include Mongoid::Document
    
    field :range_low, type: Integer
    field :range_high, type: Integer
    field :location, type: Integer
    field :coordinates, type: Array, default: []
    field :city, type: String
    field :state, type: String
    field :country, type: String  

    index range_low: -1
    
    class << self
      
      def for_ip ip
        val = ip_to_int ip
        maybe = where( :range_low.lte => val ).order_by( [[:range_low, :desc]] ).first
        if maybe.try( :range_high ).to_i >= val
          return maybe
        end
        nil
      end
      
      private
        
        def ip_to_int ip
          val = 0
          ip.split( "." ).inject( 3 ) do |exp, octet|
            val += (octet.to_i  * (256 ** exp))
            next exp - 1
          end
          val
        end
        
    end
    
  end
  
end