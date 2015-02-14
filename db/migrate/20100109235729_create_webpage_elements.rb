class CreateWebpageElements < ActiveRecord::Migration
  def self.up
    create_table :webpage_elements do |t|
      t.integer :website_url_id
      t.string :heading_path
      t.string :content_path
      t.string :data_path
      t.string :header
      t.string :merge_cells
      t.string :file_name
      t.string :sheet_name
      t.timestamps
    end
  end

  def self.down
    drop_table :webpage_elements
  end
end
