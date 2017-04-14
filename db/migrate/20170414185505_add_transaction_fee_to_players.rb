class AddTransactionFeeToPlayers < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :transaction_fee, :decimal, :precision => 7, :scale => 2
  end
end
