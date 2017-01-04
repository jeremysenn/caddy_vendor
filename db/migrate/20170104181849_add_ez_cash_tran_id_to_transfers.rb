class AddEzCashTranIdToTransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :transfers, :ez_cash_tran_id, :string
  end
end
