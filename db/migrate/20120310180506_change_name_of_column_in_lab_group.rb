class ChangeNameOfColumnInLabGroup < ActiveRecord::Migration
  def up
    rename_column(:lab_groups, :identification, :number)
  end

  def down
    rename_column(:lab_groups, :number, :identification)
  end
end
