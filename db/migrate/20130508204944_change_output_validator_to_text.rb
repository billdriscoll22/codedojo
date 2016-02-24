class ChangeOutputValidatorToText < ActiveRecord::Migration
  def up
    change_table :output_validators do |t|
      t.change :args, :text
      t.change :validator, :text
    end
  end

  def down
    change_table :output_validators do |t|
      t.change :args, :string
      t.change :validator, :string
    end
  end
end
