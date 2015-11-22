class AddPositionToItems < ActiveRecord::Migration
  def change
    add_column :items, :position, :integer, null: false, default: 0
  end
end
