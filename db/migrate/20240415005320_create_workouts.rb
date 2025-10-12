class CreateWorkouts < ActiveRecord::Migration[7.1]
  def change
    create_table :workouts do |t|
      t.string :exercise
      t.integer :series
      t.string :repetitions
      t.string :charge
      t.time :interval

      t.timestamps
    end
  end
end

t.string "exercise"
t.integer "series"
t.string "repetitions"
t.string "charge"
t.datetime "created_at", null: false
t.datetime "updated_at", null: false
t.string "interval"
t.integer "sheet_id", null: false
