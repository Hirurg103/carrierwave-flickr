module CarrierWave
  module Flickr
    module Configuration

      extend ActiveSupport::Concern

      module ClassMethods
        def flickr=(credentials)
          FlickRaw.api_key = credentials.fetch(:key)
          FlickRaw.shared_secret = credentials.fetch(:secret)

          flickr.access_token = credentials.fetch(:oauth_token)
          flickr.access_secret = credentials.fetch(:oauth_token_secret)
        end
      end
    end
  end
end
