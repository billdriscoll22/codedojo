class CreateExercises < ActiveRecord::Migration
  def change
    create_table :exercises do |t|
      t.integer :index
      t.integer :section_id
      t.text :content

      t.timestamps
    end
  end
end
