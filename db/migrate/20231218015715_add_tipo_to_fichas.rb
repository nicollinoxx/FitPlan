class AddTipoToFichas < ActiveRecord::Migration[7.0]
  def change
    add_column :fichas, :tipo, :string
  end
end
