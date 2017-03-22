class ChangeEventsClubIdToCourseId < ActiveRecord::Migration[5.0]
  def change
    rename_column :events, :club_id, :course_id
  end
end
