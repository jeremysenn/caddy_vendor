class AddClubIdToTransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :transfers, :club_id, :integer
  end
end
