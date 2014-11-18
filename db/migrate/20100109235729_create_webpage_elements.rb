class CreateWebpageElements < ActiveRecord::Migration
  def self.up
    create_table :webpage_elements do |t|
      t.integer :website_url_id
      t.integer :parameter_id
      t.string :dom_path

      t.timestamps
    end
  end

  def self.down
    drop_table :webpage_elements
  end
end
