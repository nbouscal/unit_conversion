class CreateUnits < ActiveRecord::Migration
  def change
    create_table :units do |t|
      t.string :unit_name
      t.string :symbols, array: true

      t.timestamps null: false
    end
  end
end
