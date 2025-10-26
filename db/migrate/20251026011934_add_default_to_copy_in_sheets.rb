class AddDefaultToCopyInSheets < ActiveRecord::Migration[8.0]
  def change
    change_column_default :sheets, :copy, from: nil, to: false
  end
end
