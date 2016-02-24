class AddProjTypeToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :proj_type, :string
    Exercise.all.each do |exercise|
      exercise.update_attributes!(:proj_type => 'c')
    end
  end
end
