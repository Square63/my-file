class CreateFolders < ActiveRecord::Migration
  def change
    create_table :folders do |t|
      t.string :name, null: false, default: "Folder"
      t.integer :user_id
      t.integer :parent_id

      t.timestamps
    end
  end
end
