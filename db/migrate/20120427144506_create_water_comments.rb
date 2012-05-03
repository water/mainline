class CreateWaterComments < ActiveRecord::Migration
 def up
 	create_table :comments do |t|
 		t.integer :id
 		t.integer :user_id
 		t.string :type
 		t.datetime :created_at
 		t.datetime :modified_at
 		t.text :body
        t.string :ancestry
 	end
    add_index :comments, :ancestry
 end

 	def down
 		drop_table :comments
	end
end
