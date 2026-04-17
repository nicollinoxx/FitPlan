class AddRemainingSeriesToCompletions < ActiveRecord::Migration[8.1]
  def change
    add_column :completions, :remaining_series, :integer
  end
end
