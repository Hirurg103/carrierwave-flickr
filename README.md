# Carrierwave::Flickr

## Why do you need this library?

* You want to store images in a fast and highly available storage
* You want photos to be publicly available in the Internet

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carrierwave-flickr'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install carrierwave-flickr

## Usage

Put these lines in your carriervawe initializer

```ruby
CarrierWave.configure do |config|
  config.flickr_credentials = {
    key: 'YOUR_API_KEY',
    secret: 'YOUR_SECRET',
    oauth_token: 'YOUR_TOKEN',
    oauth_token_secret: 'YOUR_TOKEN_SECRET'
  }
end
```

**This library uses [flickraw](https://github.com/hanklords/flickraw) under the hood.
See its [Authentication section](https://github.com/hanklords/flickraw#authentication) to obtain secret and token**

If you want all photos to be stored in a specific album you can specify it

```ruby
CarrierWave.configure do |config|
  config.flickr_credentials = {
    ...
    album: 'YOUR_ALBUM_ID'
  }
end
```

If you want to store photo sizes configure the column where to put them

```ruby
CarrierWave.configure do |config|
  config.store_flickr_photo_sizes = :sizes
end
```

To get an URL to the photo of a different format you can use

```ruby
  avatar.image.url(format: :square)
```

The list of available formats you can find [there](https://github.com/hanklords/flickraw#flickr-url-helpers)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hirurg103/carrierwave-flickr.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

