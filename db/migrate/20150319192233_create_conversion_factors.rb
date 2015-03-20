class CreateConversionFactors < ActiveRecord::Migration
  def change
    create_table :conversion_factors do |t|
      t.binary :compound_unit
      t.text :multiplication_factor, default: "1"
      t.text :linear_shift, default: "0"
      t.belongs_to :unit

      t.timestamps null: false
    end
  end
end
