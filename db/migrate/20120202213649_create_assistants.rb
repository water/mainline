class CreateAssistants < ActiveRecord::Migration
  def self.up
    create_table :assistants do |t|
      t.references :User

      t.timestamps
    end
  end

  def self.down
    drop_table :assistants
  end
end
