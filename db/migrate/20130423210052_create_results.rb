class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.integer :user_id
      t.integer :exercise_id
      t.boolean :is_correct

      t.timestamps
    end
  end
end
