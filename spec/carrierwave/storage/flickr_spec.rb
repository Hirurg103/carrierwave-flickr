require 'spec_helper'

describe CarrierWave::Storage::Flickr do
  before do
    allow_any_instance_of(FlickRaw::Flickr).to receive(:call)
      .with('flickr.reflection.getMethods')
      .and_return([])

    CarrierWave.configure do |config|
      config.flickr = {
        key: 'API_KEY',
        secret: 'SECRET',
        oauth_token: 'TOKEN',
        oauth_token_secret: 'SECRET'
      }
    end
  end

  def fixture_file(file)
    File.open File.expand_path("../../../fixtures/#{file}", __FILE__)
  end

  def flickr_photo_info
    info = JSON.parse(fixture_file('flickr/photo_info.json').read)
    FlickRaw::Response.build(info, 'photo')
  end

  def stub_flickr_api
    allow(flickr).to receive(:upload_photo)
      .and_return flickr_photo_info['id']

    allow(flickr).to receive_message_chain('photos.getInfo')
      .and_return flickr_photo_info
  end
  before { stub_flickr_api }


  let(:file) do
    CarrierWave::SanitizedFile.new(fixture_file 'test.jpg').tap { |f| f.content_type = 'image/jpg' }
  end

  class ImageUploader < CarrierWave::Uploader::Base
    storage :flickr
  end

  class Photo < ActiveRecord::Base
    mount_uploader :image, ImageUploader

    attr_accessor :description
  end

  def create_photo(file)
    Photo.create!(image: file)
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

  it 'should store flickr image info as an identifier' do
    photo = Photo.create image: file
    photo.save!
    expect(photo.read_attribute('image')).to eq({
      id: "33727870355",
      secret: "e68c2eaecf",
      server: "2864",
      farm: 3,
      originalsecret: "08ee278bb2" }.to_json)
  end

  it 'should retrieve photo url from the identifier' do
    photo = Photo.new
    photo.write_attribute :image, flickr_photo_info.to_json

    expect(photo.image.url).to eq 'https://farm3.staticflickr.com/2864/33727870355_08ee278bb2_o.jpg'

    expect(photo.image.url(format: :square)).to eq 'https://farm3.staticflickr.com/2864/33727870355_e68c2eaecf_s.jpg'
  end

end
