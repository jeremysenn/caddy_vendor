class AddClubCreditTranIdToTransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :transfers, :club_credit_transaction_id, :integer
  end
end
