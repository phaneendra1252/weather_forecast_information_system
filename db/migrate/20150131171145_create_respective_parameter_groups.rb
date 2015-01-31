class CreateRespectiveParameterGroups < ActiveRecord::Migration
  def change
    create_table :respective_parameter_groups do |t|
      t.integer :website_url_id
    end
  end
end