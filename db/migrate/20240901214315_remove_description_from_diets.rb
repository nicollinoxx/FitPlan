class RemoveDescriptionFromDiets < ActiveRecord::Migration[7.1]
  def change
    remove_column :diets, :description, :text
  end
end
