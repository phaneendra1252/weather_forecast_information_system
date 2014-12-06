class CreateImdStates < ActiveRecord::Migration
  def change
    create_table :imd_states do |t|
      t.string :name
      t.integer :code
      t.timestamps
    end
  end
end
