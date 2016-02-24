class CreateTagsTutorialsJoinTable < ActiveRecord::Migration
  def up
  	create_table :tags_tutorials, :id => false do |t|
  		t.integer :tag_id
  		t.integer :tutorial_id
  	end
  	add_index :tags_tutorials, [:tag_id, :tutorial_id]
  end

  def down
  	drop_table :tags_tutorials
  end
end
