class AddFileToTransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :transfers, :file, :string
  end
end
