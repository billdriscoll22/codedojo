class CreateTemplateFiles < ActiveRecord::Migration
  def change
    create_table :template_files do |t|
      t.string :file_name
      t.integer :exercise_id
      t.text :content

      t.timestamps
    end
  end
end
