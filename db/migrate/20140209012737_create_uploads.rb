class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :name
      t.string :content_type
      t.string :path
      t.string :md5
      t.integer :size

      t.timestamps
    end
  end
end
