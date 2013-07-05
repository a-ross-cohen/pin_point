# PinPoint

TODO: Write a gem description

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

Be aware that this imports over 2 million IP Blocks and then maps each of them to a location. This operation takes a while, even on fast machines.

Once the data is all imported you can look up blocks based on IP strings:

``` ruby
PinPoint.ip '173.194.68.104'
=> #<PinPoint::IpBlock _id: 51d49c03be8a5c023d1cc080, range_low: 3495038258, range_high: 3495038258, location: 618, coordinates: [], city: nil, state: nil, country: nil>
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

See LICENSE.txt
