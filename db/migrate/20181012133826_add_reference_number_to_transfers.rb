class AddReferenceNumberToTransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :transfers, :reference_number, :integer
  end
end
