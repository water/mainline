class CreateWhens < ActiveRecord::Migration
  def self.up
    create_table :whens do |t|
      t.integer :year
      t.integer :study_period

      t.timestamps
    end
  end

  def self.down
    drop_table :whens
  end
end
