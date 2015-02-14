class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.integer :website_id
      t.string :url
      t.timestamps
    end
  end
end
