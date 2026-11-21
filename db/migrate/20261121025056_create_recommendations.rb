class CreateRecommendations < ActiveRecord::Migration[8.1]
  def change
    create_table :recommendations do |t|
      t.references :user,  null: false, foreign_key: true
      t.references :sheet, foreign_key: { on_delete: :nullify }
      t.string     :token, null: false
      t.datetime   :accepted_at
      t.timestamps
    end
    add_index :recommendations, %i[ user_id token ], unique: true

    add_reference :sheets, :recommendation, foreign_key: { on_delete: :nullify }
  end
end
