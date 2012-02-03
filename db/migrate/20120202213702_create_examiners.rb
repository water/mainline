class CreateExaminers < ActiveRecord::Migration
  def self.up
    create_table :examiners do |t|
      t.references :User

      t.timestamps
    end
  end

  def self.down
    drop_table :examiners
  end
end
