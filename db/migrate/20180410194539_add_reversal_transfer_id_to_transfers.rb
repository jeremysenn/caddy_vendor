class AddReversalTransferIdToTransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :transfers, :original_transfer_id, :integer
  end
end
