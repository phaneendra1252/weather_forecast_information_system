class CreateVisitParameters < ActiveRecord::Migration
  def change
    create_table :visit_parameters do |t|
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
