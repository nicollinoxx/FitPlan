class AddSheetIdToWorkouts < ActiveRecord::Migration[7.1]
  def change
    add_reference :workouts, :sheet, null: false, foreign_key: true
  end
end
