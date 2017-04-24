require 'carrierwave/storage/abstract'
require 'flickraw'

module CarrierWave
  module Storage
    class Flickr < Abstract

      def store!(file)
        f = CarrierWave::Storage::Flickr::File.new(uploader, self)
        @info = f.store(file)
        store_identifier
        store_sizes if store_sizes?
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
          'originalsecret',
          'originalformat').to_json
      end

      private

      def store_identifier
        column = @uploader.mounted_as
        model = @uploader.model

        model.public_send(:"write_#{column}_identifier")
      end

      def store_sizes
        photo_sizes = flickr.photos.getSizes 'photo_id' => @info['id']

        model = @uploader.model

        model.update_column uploader.store_flickr_photo_sizes, prepare_sizes(photo_sizes)
      end

      def prepare_sizes(raw_sizes)
        raw_sizes.each_with_object({}) do |raw_size, sizes|
          key = raw_size['label'].downcase.gsub(/ /, '_').to_sym

          sizes[key] = {
            height: raw_size['height'].to_i,
            width: raw_size['width'].to_i
          }
        end
      end

      def store_sizes?
        uploader.store_flickr_photo_sizes.present?
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

        def path
          url
        end

        def store(new_file)
          file = new_file.to_file

          photo_id = flickr.upload_photo file, **store_options

          add_to_album(photo_id) if album.present?

          apply_license(photo_id, license_id) if license_id.present?

          file.close if file && !file.closed?

          @info = flickr.photos.getInfo('photo_id' => photo_id)
        end

        def delete
          flickr.photos.delete 'photo_id' => @info['id']
        end

        private

        def add_to_album(photo_id)
          flickr.photosets.addPhoto(
            'photo_id' => photo_id,
            'photoset_id' => album)
        end

        def album
          @uploader.flickr_credentials[:album]
        end

        def apply_license(photo_id, license_id)
          flickr.photos.licenses.setLicense(
            'license_id' => license_id,
            'photo_id' => photo_id)
        end

        def license_id
          @uploader.flickr_credentials[:license_id]
        end

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
