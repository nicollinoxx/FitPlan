class ChangeRepetitionsTypeInWorkouts < ActiveRecord::Migration[7.1]
  def change
    change_column :workouts, :repetitions, :integer
  end
end
