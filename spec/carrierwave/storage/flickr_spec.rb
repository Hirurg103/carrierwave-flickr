require 'spec_helper'

describe CarrierWave::Storage::Flickr do
  def configure!(flickr_credentials = {})
    ImageUploader.configure do |config|
      config.flickr_credentials = flickr_credentials.reverse_merge(
        key: 'API_KEY',
        secret: 'SECRET',
        oauth_token: 'TOKEN',
        oauth_token_secret: 'SECRET')
    end
  end

  before do
    allow_any_instance_of(FlickRaw::Flickr).to receive(:call)
      .with('flickr.reflection.getMethods')
      .and_return([])

    configure!
  end

  def fixture_file(file)
    File.open File.expand_path("../../../fixtures/#{file}", __FILE__)
  end

  def flickr_photo_info(photo = 'photo_info')
    info = JSON.parse(fixture_file("flickr/#{photo}.json").read)
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

    serialize :sizes, Hash
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
      originalsecret: "08ee278bb2",
      originalformat: "jpg" }.to_json)
  end

  it 'should retrieve photo url from the identifier' do
    photo = Photo.new
    photo.write_attribute :image, flickr_photo_info.to_json

    expect(photo.image.url).to eq 'https://farm3.staticflickr.com/2864/33727870355_08ee278bb2_o.jpg'

    expect(photo.image.url(format: :square)).to eq 'https://farm3.staticflickr.com/2864/33727870355_e68c2eaecf_s.jpg'
  end

  let(:new_file) do
    CarrierWave::SanitizedFile.new(fixture_file 'test1.jpg').tap { |f| f.content_type = 'image/jpg' }
  end

  it 'should replace image when saving a new photo' do
    old_photo_info = flickr_photo_info
    photo = create_photo file

    photo.image = new_file

    new_photo_info = flickr_photo_info('another_photo_info')
    allow(flickr).to receive_message_chain('photos.getInfo').and_return new_photo_info

    expect(flickr).to receive(:upload_photo) do |cached_file|
      expect(cached_file.read).to eq new_file.read
    end
    expect(flickr).to receive_message_chain('photos.delete')
      .with('photo_id' => old_photo_info['id'])
    photo.save!
  end

  it 'should delete old flickr photo when downloading a new photo from an url' do
    old_photo_info = flickr_photo_info
    photo = Photo.new
    photo.image.download! 'http://c1.staticflickr.com/1/688/21892142671_31a26968a0_z.jpg'
    photo.save!

    photo.image.download! 'http://c1.staticflickr.com/1/422/18982103459_0ce32d2fe4_n.jpg'

    new_photo_info = flickr_photo_info('another_photo_info')
    allow(flickr).to receive_message_chain('photos.getInfo').and_return new_photo_info

    expect(flickr).to receive(:upload_photo)
    expect(flickr).to receive_message_chain('photos.delete')
      .with('photo_id' => old_photo_info['id'])
    photo.save!
  end

  it 'should delete flickr photo when destroying a photo' do
    photo = create_photo file

    expect(flickr).to receive_message_chain('photos.delete')
       .with('photo_id' => flickr_photo_info['id'])
    photo.destroy!
  end

  it 'should put photo into an album if the album is configured' do
    configure! album: '72157624618609504'

    expect(flickr).to receive_message_chain('photosets.addPhoto')
      .with('photoset_id' => '72157624618609504', 'photo_id' => '33727870355')

    create_photo file

    configure! album: nil
  end

  def flickr_photo_sizes
    sizes = JSON.parse(fixture_file("flickr/photo_sizes.json").read)
    FlickRaw::Response.build({ 'size' => sizes }, 'sizes')
  end

  it 'should store image dimensions in the column specified in the configuration' do
    ImageUploader.configure do |config|
      config.store_flickr_photo_sizes = :sizes
    end

    allow(flickr).to receive_message_chain('photos.getSizes').and_return flickr_photo_sizes
    photo = create_photo file

    expect(photo.reload.sizes).to match hash_including({
      small: {
        height: 180,
        width: 240
      },
      medium: {
        height: 375,
        width: 500
      },
      large: {
        height: 768,
        width: 1024
      },
      original: {
        height: 1200,
        width: 1600
      }
    })

    ImageUploader.configure do |config|
      config.store_flickr_photo_sizes = nil
    end
  end

  it 'should apply a license if it is specified' do
    configure! license_id: '9'

    expect(flickr).to receive_message_chain('photos.licenses.setLicense')
     .with('license_id' => '9', 'photo_id' => '33727870355')

    create_photo file

    configure! license_id: nil
  end

end
