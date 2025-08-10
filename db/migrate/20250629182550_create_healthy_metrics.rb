class CreateHealthyMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :healthy_metrics do |t|
      t.decimal :height
      t.decimal :weight
      t.date    :birth_date
      t.string  :gender
      t.decimal :imc
      t.decimal :tmb
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
