ActiveRecord::Schema.define do
  self.verbose = false

  create_table :photos, force: true do |t|
    t.string :title
    t.text :image

    t.timestamps
  end

end
