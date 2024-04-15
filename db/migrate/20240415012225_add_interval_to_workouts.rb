class AddIntervalToWorkouts < ActiveRecord::Migration[7.1]
  def change
    add_column :workouts, :interval, :string
  end
end
