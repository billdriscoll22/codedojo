class AddRenderedContentToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :rendered_content, :text
  end
end
