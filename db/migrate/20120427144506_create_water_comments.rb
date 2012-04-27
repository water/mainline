class CreateWaterComments < ActiveRecord::Migration
 def up
 	create_table :comments do |t|
 		t.integer :id
 		t.integer :user_id
 		t.integer :parent_id
 		t.string :type
 		t.datetime :created_at
 		t.datetime :modified_at
 		t.text :body
 	end
 end

 	def down
 		drop_table :comments
	end
end
