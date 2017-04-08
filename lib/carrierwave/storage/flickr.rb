require 'carrierwave/storage/abstract'
require 'flickraw'

module CarrierWave
  module Storage
    class Flickr < Abstract

      def store!(file)
        f = CarrierWave::Storage::Flickr::File.new(uploader, self)
        f.store(file)
        f
      end

      class File
        def initialize(uploader, base)
          @uploader = uploader
          @base = base
        end

        def store(new_file)
          file = new_file.to_file

          flickr.upload_photo file, **store_options

          file.close if file && !file.closed?
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

      end

    end
  end
end
