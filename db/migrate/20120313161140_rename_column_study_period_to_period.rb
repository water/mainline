class RenameColumnStudyPeriodToPeriod < ActiveRecord::Migration
  def up
    rename_column :study_periods, :study_period, :period
  end

  def down
    rename_column :study_periods, :period, :study_period
  end
end
