class AddPositionToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :position, :integer, null: false, default: 0
    add_index :projects, :position
  end
end
