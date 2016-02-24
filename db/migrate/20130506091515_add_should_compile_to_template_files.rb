class AddShouldCompileToTemplateFiles < ActiveRecord::Migration
  def change
    add_column :template_files, :should_compile, :boolean
  end
end
