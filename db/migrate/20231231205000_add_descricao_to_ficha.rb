class AddDescricaoToFicha < ActiveRecord::Migration[7.0]
  def change
    add_column :fichas, :descricao, :string
  end
end
