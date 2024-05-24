class ChangeSeriesTypeInWorkouts < ActiveRecord::Migration[7.1]
  def change
    change_column :workouts, :series, :integer
  end
end
