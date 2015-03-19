class AddConversionFactorToUnit < ActiveRecord::Migration
  def change
    add_column :units, :conversion_factor, :text
  end
end
