require 'carrierwave/storage/abstract'
require 'flickraw'

module CarrierWave
  module Storage
    class Flickr < Abstract

      def store!(file)
        f = CarrierWave::Storage::Flickr::File.new(uploader, self)
        @info = f.store(file)
        store_identifier
        f
      end

      def retrieve!(identifier)
        info = JSON.parse(identifier)
        CarrierWave::Storage::Flickr::File.new(uploader, self, info)
      end

      def identifier
        (@info.as_json || {}).slice(
          'id',
          'secret',
          'server',
          'farm',
          'originalsecret').to_json
      end

      private

      def store_identifier
        column = @uploader.mounted_as
        model = @uploader.model

        model.public_send(:"write_#{column}_identifier")

        model.update_column column, model.read_attribute(column)
      end


      class File
        def initialize(uploader, base, info = nil)
          @uploader = uploader
          @base = base
          @info = FlickRaw::Response.build(info, 'photo') if info
        end

        def url(format: :original)
          FlickRaw.public_send(format_getter(format), @info) if @info
        end

        def store(new_file)
          file = new_file.to_file

          photo_id = flickr.upload_photo file, **store_options

          file.close if file && !file.closed?

          @info = flickr.photos.getInfo('photo_id' => photo_id)
        end

        private

        def store_options
          {}.tap do |options|
            options[:title] = model.title if model.respond_to?(:title)
            options[:description] = model.description if model.respond_to?(:description)
          end.reject { |k, v| v.blank? }
        end

        def model
          @uploader.model
        end

        def format_getter(format)
          {
            square:       :url_s,
            large_square: :url_q,
            thumbnail:    :url_t,
            small:        :url_m,
            small_320:    :url_n,
            medium:       :url,
            medium_640:   :url_z,
            medium_800:   :url_c,
            large:        :url_b,
            original:     :url_o
          }.fetch(format)
        end
      end

    end
  end
end
