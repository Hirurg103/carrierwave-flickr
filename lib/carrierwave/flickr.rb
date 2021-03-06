require "carrierwave/flickr/version"
require "carrierwave/storage/flickr"

module CarrierWave
  module Flickr
  end
end

require 'carrierwave'
CarrierWave.configure do |config|
  config.storage_engines[:flickr] = 'CarrierWave::Storage::Flickr'
end

require 'carrierwave/flickr/configuration'
CarrierWave::Uploader::Base.include(CarrierWave::Flickr::Configuration)

if defined?(Rails)
  module CarrierWave
    module Flickr
      class Railtie < Rails::Railtie
        initializer "carrierwave-flickr.active_record" do
          ActiveSupport.on_load :active_record do
            require 'carrierwave/flickr/active_record'
          end
        end
      end
    end
  end
end
