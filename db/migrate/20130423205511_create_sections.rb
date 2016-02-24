class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :subtitle
      t.text :content
      t.integer :index
      t.integer :tutorial_id

      t.timestamps
    end
  end
end
