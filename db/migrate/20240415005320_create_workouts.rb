class CreateWorkouts < ActiveRecord::Migration[7.1]
  def change
    create_table :workouts do |t|
      t.string :exercise
      t.integer :series
      t.string :repetitions
      t.string :charge

      t.timestamps
    end
  end
end
