# PinPoint

Pinpoint a users location by their IP address.

## Installation

Add this line to your application's Gemfile:

    gem 'pin_point'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pin_point

## Usage

To import the IP Block and location mapping data just run the provided rake task in your apps root directory:

  $ rake pin_point:import

Be aware that this imports over 2 million IP Blocks and then maps each of them to a location. This operation takes a while ( 30+ minutes ), even on fast machines.

Once the data is all imported you can look up blocks based on IP strings:

``` ruby
PinPoint.ip '173.194.43.1'
=> #<PinPoint::IpBlock _id: 51e5ec3fbe8a5cbd5417c2ee,
      range_low: 2915172352,
      range_high: 2915197695,
      location: 2703,
      coordinates: [-122.0574, 37.4192],
      city: "Mountain View",
      state: "CA",
      country: "US"> 
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

See LICENSE.txt
