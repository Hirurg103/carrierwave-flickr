module CarrierWave
  module Flickr
    module ActiveRecord
      private

      def mount_base(column, uploader=nil, options={}, &block)
        super

        after_save :"store_flickr_#{column}_identifier"
        class_eval <<-RUBY, __FILE__, __LINE__+1
          def store_flickr_#{column}_identifier
            update_column :"#{column}", read_attribute(:"#{column}")
          end
        RUBY
      end

    end
  end
end

ActiveRecord::Base.extend CarrierWave::Flickr::ActiveRecord
