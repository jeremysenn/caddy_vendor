class CreatePlayers < ActiveRecord::Migration[5.0]
  def change
    create_table :players do |t|
      t.belongs_to :member, foreign_key: true
      t.belongs_to :caddy, foreign_key: true
      t.belongs_to :event, foreign_key: true
      t.string :caddy_type
      t.string :status
      t.integer :round
      t.decimal :fee, :precision => 7, :scale => 2
      t.decimal :tip, :precision => 7, :scale => 2

      t.timestamps
    end
  end
end
