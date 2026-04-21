class ChangeWorkoutIntervalToTime < ActiveRecord::Migration[8.1]
  def change
    change_column :workouts, :interval, :integer, using: 0
  end
end
