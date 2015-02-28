class CreateWebpageElements < ActiveRecord::Migration
  def change
    create_table :webpage_elements do |t|
      t.integer :website_url_id
      t.string :heading_path
      t.string :content_path
      t.string :data_path
      t.string :header_path
      t.string :folder_path
      t.string :file_name
      t.string :sheet_name
      t.string :group_by_element
      t.timestamps
    end
  end
end