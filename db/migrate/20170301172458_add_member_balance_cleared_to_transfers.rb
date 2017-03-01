class AddMemberBalanceClearedToTransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :transfers, :member_balance_cleared, :boolean, default: false
  end
end
