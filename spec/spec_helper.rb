$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'carrierwave/flickr'

require 'active_record'
require 'carrierwave/orm/activerecord'
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

require 'pry'
