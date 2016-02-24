class AddShouldCompileToUserFiles < ActiveRecord::Migration
  def change
    add_column :user_files, :should_compile, :boolean
    UserFile.all.each do |user_file|
      user_file.update_attributes!(:should_compile => true)
    end
  end
end
