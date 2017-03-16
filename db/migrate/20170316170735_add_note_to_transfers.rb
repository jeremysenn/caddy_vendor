class AddNoteToTransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :transfers, :note, :string
  end
end
