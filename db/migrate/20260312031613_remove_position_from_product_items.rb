class RemovePositionFromProductItems < ActiveRecord::Migration[8.1]
  def change
    remove_column :product_items, :position, :integer
  end
end
