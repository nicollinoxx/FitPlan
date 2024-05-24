class ChangeRepetitionsColumnInWorkouts < ActiveRecord::Migration[7.1]
  def change
    change_column :workouts, :series, :integer
    change_column :workouts, :repetitions, :string
  end
end
