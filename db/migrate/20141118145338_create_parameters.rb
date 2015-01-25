class CreateParameters < ActiveRecord::Migration
  def change
    create_table :parameters do |t|
      t.integer :website_url_id
      t.string :symbol
      t.string :value

      t.timestamps
    end
  end
end