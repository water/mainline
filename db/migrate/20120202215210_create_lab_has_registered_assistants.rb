class CreateLabHasRegisteredAssistants < ActiveRecord::Migration
  def self.up
    create_table :lab_has_registered_assistants do |t|
      t.references :AssistantRegisteredToGivenCourse
      t.references :Lab
      t.references :When

      t.timestamps
    end
  end

  def self.down
    drop_table :lab_has_registered_assistants
  end
end
