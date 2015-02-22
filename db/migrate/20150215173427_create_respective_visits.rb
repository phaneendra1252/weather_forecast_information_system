class CreateRespectiveVisits < ActiveRecord::Migration
  def change
    create_table :respective_visits do |t|
      t.integer :visit_id
      t.string :content_path
      t.string :data_path
      t.string :symbol
      t.string :data_type
      t.string :ignore_value
      t.timestamps
    end
  end
end
