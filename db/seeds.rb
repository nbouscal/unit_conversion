# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def create_base_unit(unit_name, symbols)
  unit = Unit.create(unit_name: unit_name, symbols: symbols)
  unit.conversion_factor = ConversionFactor.new()
  unit.conversion_factor.unit = [Unit::CUnit.new(unit, 1)]
  unit.conversion_factor.save
  unit.save
end

create_base_unit('meter', ['m'])
create_base_unit('second', ['s'])
create_base_unit('kilogram', ['kg'])
create_base_unit('ampere', ['Ω'])
create_base_unit('candela', ['cd'])
create_base_unit('kelvin', ['K'])
create_base_unit('mole', ['mol'])
create_base_unit('radian', ['rad'])

def create_derived_unit(unit_name, symbols, cf)
  unit = Unit.create(unit_name: unit_name, symbols: symbols)
  unit.conversion_factor = cf
  unit.save
end

meter = Unit.find_by unit_name: 'meter'
meter_cu = [Unit::CUnit.new(meter, 1)]
second = Unit.find_by unit_name: 'second'
second_cu = [Unit::CUnit.new(second, 1)]
kilogram = Unit.find_by unit_name: 'kilogram'
kilogram_cu = [Unit::CUnit.new(kilogram, 1)]

minute_cf = ConversionFactor.new(multiplication_factor: Rational(60))
minute_cf.unit = second_cu
minute_cf.save

minute = Unit.create(unit_name: 'minute', symbols: ['min'])
minute.conversion_factor = minute_cf
minute.save
