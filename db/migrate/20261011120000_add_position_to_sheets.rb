class AddPositionToSheets < ActiveRecord::Migration[8.1]
  def up
    add_column :sheets, :position, :integer

    execute <<~SQL
      UPDATE sheets SET position = ranked.position
      FROM (SELECT id, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at, id) AS position FROM sheets) ranked
      WHERE sheets.id = ranked.id
    SQL

    change_column_null :sheets, :position, false
    add_index :sheets, [ :user_id, :position ]
  end

  def down
    remove_column :sheets, :position
  end
end
