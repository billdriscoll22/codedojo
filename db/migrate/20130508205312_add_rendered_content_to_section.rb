class AddRenderedContentToSection < ActiveRecord::Migration
  def change
    add_column :sections, :rendered_content, :text
  end
end
