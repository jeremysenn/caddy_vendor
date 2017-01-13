class AddNoteStringToPlayers < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :note, :string
  end
end
