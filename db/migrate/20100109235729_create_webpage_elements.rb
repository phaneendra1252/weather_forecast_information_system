class CreateWebpageElements < ActiveRecord::Migration
  def self.up
    create_table :webpage_elements do |t|
      t.string :heading_path
      t.string :content_path
      t.string :header
      t.string :merge_cells
      t.timestamps
    end
  end

  def self.down
    drop_table :webpage_elements
  end
end
