# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

meter    = Unit.create(unit_name: 'meter', symbols: ['m'])
second   = Unit.create(unit_name: 'second', symbols: ['s'])
kilogram = Unit.create(unit_name: 'kilogram', symbols: ['kg'])
ampere   = Unit.create(unit_name: 'ampere', symbols: ['Ω'])
candela  = Unit.create(unit_name: 'candela', symbols: ['cd'])
kelvin   = Unit.create(unit_name: 'kelvin', symbols: ['K'])
mole     = Unit.create(unit_name: 'mole', symbols: ['mol'])

meter.conversion_factor    = ConversionFactor.create(compound_unit: [Unit::CUnit.new(meter, 1)])
second.conversion_factor   = ConversionFactor.create(compound_unit: [Unit::CUnit.new(second, 1)])
kilogram.conversion_factor = ConversionFactor.create(compound_unit: [Unit::CUnit.new(kilogram, 1)])
ampere.conversion_factor   = ConversionFactor.create(compound_unit: [Unit::CUnit.new(ampere, 1)])
candela.conversion_factor  = ConversionFactor.create(compound_unit: [Unit::CUnit.new(candela, 1)])
kelvin.conversion_factor   = ConversionFactor.create(compound_unit: [Unit::CUnit.new(kelvin, 1)])
mole.conversion_factor     = ConversionFactor.create(compound_unit: [Unit::CUnit.new(mole, 1)])

meter.save
second.save
kilogram.save
ampere.save
candela.save
kelvin.save
mole.save
