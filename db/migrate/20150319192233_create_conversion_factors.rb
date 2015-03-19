class CreateConversionFactors < ActiveRecord::Migration
  def change
    create_table :conversion_factors do |t|
      t.text :multiplication_factor
      t.text :linear_shift

      t.timestamps null: false
    end
  end
end
