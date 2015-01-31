class CreateWebpageElementsWebsiteUrls < ActiveRecord::Migration
  def change
    create_table :webpage_elements_website_urls do |t|
      t.integer :website_url_id
      t.integer :webpage_element_id
      t.timestamps
    end
  end
end
