class CreateOutputValidators < ActiveRecord::Migration
  def change
    create_table :output_validators do |t|
      t.string :args
      t.integer :exercise_id
      t.string :validator

      t.timestamps
    end
  end
end
