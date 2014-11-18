class CreateWebsiteUrls < ActiveRecord::Migration
  def self.up
    create_table :website_urls do |t|
      t.integer :website_id
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :website_urls
  end
end
