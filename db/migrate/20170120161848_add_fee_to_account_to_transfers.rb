class AddFeeToAccountToTransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :transfers, :fee_to_account_id, :integer
  end
end
