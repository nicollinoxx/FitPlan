class AddSeenAtToFollows < ActiveRecord::Migration[8.1]
  def change
    add_column :follows, :seen_at, :datetime
  end
end
