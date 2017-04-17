module CarrierWave
  module Flickr
    module Configuration

      extend ActiveSupport::Concern

      included do
        add_config :flickr_credentials
        add_config :store_flickr_photo_sizes

        class << self
          alias_method :flickr_without_configuration=, :flickr_credentials=
          alias_method :flickr_credentials=, :flickr_with_configuration=
        end
      end

      module ClassMethods

        def flickr_with_configuration=(credentials)
          self.flickr_without_configuration = credentials

          FlickRaw.api_key = credentials[:key]
          FlickRaw.shared_secret = credentials[:secret]

          flickr.access_token = credentials[:oauth_token]
          flickr.access_secret = credentials[:oauth_token_secret]
        end
      end
    end
  end
end
