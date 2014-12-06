class CreateImdAwsData < ActiveRecord::Migration
  def change
    create_table :imd_aws_data do |t|
      t.integer :sr_no
      t.string :station_name
      t.date :parse_date
      t.time :time_utc
      t.float :latitude_n
      t.float :longitude_e
      t.float :slp_hpa
      t.float :mslp_hpa
      t.float :rainfall_mm
      t.float :temperature_deg_c
      t.integer :imd_state_id
      t.timestamps
    end
  end
end
