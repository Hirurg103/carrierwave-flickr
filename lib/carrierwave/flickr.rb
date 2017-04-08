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
