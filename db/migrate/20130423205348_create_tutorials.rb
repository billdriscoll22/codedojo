class CreateTutorials < ActiveRecord::Migration
  def change
    create_table :tutorials do |t|
      t.integer :num_ratings
      t.text :description
      t.string :title
      t.integer :difficulty
      t.float :rating
      t.integer :user_id
      t.integer :category_id

      t.timestamps
    end
  end
end
