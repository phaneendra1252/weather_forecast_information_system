class CreateRespectiveParameters < ActiveRecord::Migration
  def change
    create_table :respective_parameters do |t|
      t.integer :respective_parameter_group_id
      t.string :symbol
      t.string :value
      t.timestamps
    end
  end
end