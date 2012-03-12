class RenameWhenIdFkToStudyPeriodId < ActiveRecord::Migration
  def up
    rename_column :lab_descriptions, :when_id, :study_period_id
    rename_column :given_courses, :when_id, :study_period_id
  end

  def down
    rename_column :lab_descriptions, :study_period_id, :when_id
    rename_column :given_courses, :study_period_id, :when_id
  end
end
