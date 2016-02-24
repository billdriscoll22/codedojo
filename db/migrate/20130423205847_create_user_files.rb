class CreateUserFiles < ActiveRecord::Migration
  def change
    create_table :user_files do |t|
      t.integer :user_id
      t.integer :exercise_id
      t.text :content
      t.string :file_name

      t.timestamps
    end
  end
end
