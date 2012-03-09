class RenameCamelCasedColumnsInLabs < ActiveRecord::Migration
  def up
    rename_column :labs, :GivenCourse_id, :given_course_id
    rename_column :labs, :LabDescription_id, :lab_description_id
  end

  def down
  end
end