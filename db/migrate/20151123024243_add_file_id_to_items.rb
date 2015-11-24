class AddFileIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :file_id, :integer
  end
end
