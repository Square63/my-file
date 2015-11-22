class AddIndexesToItems < ActiveRecord::Migration
  def change
    add_index :items, :parent_id
    add_index :items, :user_id
  end
end
