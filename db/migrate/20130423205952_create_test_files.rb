class CreateTestFiles < ActiveRecord::Migration
  def change
    create_table :test_files do |t|
      t.string :file_name
      t.integer :exercise_id
      t.text :content

      t.timestamps
    end
  end
end
