class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.string :content_type, limit: 32
      t.string :type, limit: 8
      t.string :md5, limit: 32
      t.integer :size, null: false, default: 0
      t.integer :user_id
      t.integer :parent_id

      t.timestamps
    end
  end
end
