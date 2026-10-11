class AddPositionToWorkoutsAndDiets < ActiveRecord::Migration[8.1]
  def up
    %i[ workouts diets ].each do |table|
      add_column table, :position, :integer

      execute <<~SQL
        UPDATE #{table} SET position = ranked.position
        FROM (SELECT id, ROW_NUMBER() OVER (PARTITION BY sheet_id ORDER BY created_at, id) AS position FROM #{table}) ranked
        WHERE #{table}.id = ranked.id
      SQL

      change_column_null table, :position, false
      add_index table, [ :sheet_id, :position ]
    end
  end

  def down
    remove_column :workouts, :position
    remove_column :diets, :position
  end
end
