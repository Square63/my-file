class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.string :name
      t.string :content_type, limit: 32
      t.string :md5, limit: 32
      t.integer :size, null: false, default: 0

      t.timestamps
    end
  end
end
