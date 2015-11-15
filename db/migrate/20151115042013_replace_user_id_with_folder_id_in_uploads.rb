class ReplaceUserIdWithFolderIdInUploads < ActiveRecord::Migration
  def up
    remove_column :uploads, :user_id
    add_column :uploads, :folder_id, :integer
    add_index :uploads, :folder_id
  end

  def down
    add_column :uploads, :user_id, :integer
    add_index :uploads, :user_id
    remove_column :uploads, :folder_id, :integer
  end
end
