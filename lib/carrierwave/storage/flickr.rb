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

          flickr.upload_photo file

          file.close if file && !file.closed?
        end

      end

    end
  end
end
