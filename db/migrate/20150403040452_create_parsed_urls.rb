class CreateParsedUrls < ActiveRecord::Migration
  def change
    create_table :parsed_urls do |t|
      t.date :date
      t.string :website_name
      t.integer :website_id
      t.string :string
      t.string :url

      t.timestamps
    end
  end
end
