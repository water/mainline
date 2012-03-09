class AddGradeToLabHasGroup < ActiveRecord::Migration
  def change
    add_column :lab_has_groups, :grade, :string
  end
end
