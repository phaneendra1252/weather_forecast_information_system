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
      t.float :dew_point_deg_c
      t.float :wind_speed_kt
      t.float :wind_dir_deg
      t.float :tmax_deg_c
      t.float :tmin_deg_c
      t.float :ptend_hpa
      t.float :sshm
      t.integer :imd_state_id
      t.timestamps
    end
  end
end