require 'spec_helper'

describe CarrierWave::Storage::Flickr do
  def stub_flickr_api
    allow_any_instance_of(FlickRaw::Flickr).to receive(:call)
      .with('flickr.reflection.getMethods')
      .and_return([])
  end
  before { stub_flickr_api }

  before do
    CarrierWave.configure do |config|
      config.flickr = {
        key: 'API_KEY',
        secret: 'SECRET',
        oauth_token: 'TOKEN',
        oauth_token_secret: 'SECRET'
      }
    end
  end

  let(:file) do
    file = File.open File.expand_path('../../../fixtures/test.jpg', __FILE__)
    CarrierWave::SanitizedFile.new(file).tap { |f| f.content_type = 'image/jpg' }
  end

  class ImageUploader < CarrierWave::Uploader::Base
    storage :flickr
  end

  class Photo < ActiveRecord::Base
    mount_uploader :image, ImageUploader

    attr_accessor :description
  end

  def create_photo(file)
    Photo.create(image: file)
  end

  it 'should upload an image to flickr when creating a photo' do
    expect_any_instance_of(FlickRaw::Flickr).to receive(:upload_photo) do |cached_file|
      expect(cached_file.read).to eq file.read
    end

    create_photo(file)
  end

  it 'should store a photo title when it is provided' do
    expect(flickr).to receive(:upload_photo).with(anything, title: 'My Cat')

    photo = Photo.new image: file, title: 'My Cat'
    photo.save!
  end


  it 'should store a photo description when it is specified' do
    expect(flickr).to receive(:upload_photo)
     .with(anything, hash_including(description: 'My Dog'))

    photo = Photo.new image: file, description: 'My Dog'
    photo.save!
  end
end
