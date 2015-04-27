class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :website_name
      t.string :file_name
      t.date :yesterday_date
      t.date :today_date
      t.integer :yesterday_row_count
      t.integer :today_row_count
      t.integer :row_count_difference
      t.integer :yesterday_column_count
      t.integer :today_column_count
      t.integer :column_count_difference
      t.timestamps
    end
  end
end
