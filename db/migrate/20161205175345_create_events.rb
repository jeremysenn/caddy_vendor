class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string :title
      t.datetime :start
      t.datetime :end
      t.string :color
      
      t.string :size
      t.string :round
      t.text :notes
      t.belongs_to :club, index: true
      
      t.timestamps
    end
  end
end
