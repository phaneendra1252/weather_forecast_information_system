class CreateWebsiteUrls < ActiveRecord::Migration
  def change
    create_table :website_urls do |t|
      t.integer :website_id
      t.string :url
      t.timestamps
    end
  end
end