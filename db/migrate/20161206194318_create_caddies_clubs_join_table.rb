class CreateCaddiesClubsJoinTable < ActiveRecord::Migration[5.0]
  def change
    create_join_table :caddies, :clubs do |t|
      t.index :caddy_id
      t.index :club_id
    end
  end
end
