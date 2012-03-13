class RenameWhensToStudyPeriods < ActiveRecord::Migration
  def up
    rename_table :whens, :study_periods
  end

  def down
    rename_table :study_periods, :whens
  end
end
