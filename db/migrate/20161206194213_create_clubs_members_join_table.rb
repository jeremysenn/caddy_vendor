class CreateClubsMembersJoinTable < ActiveRecord::Migration[5.0]
  def change
    create_join_table :clubs, :members do |t|
      t.index :club_id
      t.index :member_id
    end
  end
end
