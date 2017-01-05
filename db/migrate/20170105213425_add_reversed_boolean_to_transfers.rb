class AddReversedBooleanToTransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :transfers, :reversed, :boolean, default: false
  end
end
