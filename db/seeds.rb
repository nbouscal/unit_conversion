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
create_base_unit('neper', ['Np'])

def create_derived_unit(unit_name, symbols, mf, cu)
  unit = Unit.create(unit_name: unit_name, symbols: symbols)
  cf = create_cf(mf, cu)
  unit.conversion_factor = cf
  unit.save
end

def create_cf(mf, cu)
  cf = ConversionFactor.new(multiplication_factor: mf)
  cf.unit = cu
  cf.save
  cf
end

meter = Unit.find_by unit_name: 'meter'
meter2_cu = [Unit::CUnit.new(meter, 2)]
meter3_cu = [Unit::CUnit.new(meter, 3)]
second = Unit.find_by unit_name: 'second'
second_cu = [Unit::CUnit.new(second, 1)]
kilogram = Unit.find_by unit_name: 'kilogram'
kilogram_cu = [Unit::CUnit.new(kilogram, 1)]
radian = Unit.find_by unit_name: 'radian'
radian_cu = [Unit::CUnit.new(radian, 1)]
neper = Unit.find_by unit_name: 'neper'
neper_cu = [Unit::CUnit.new(neper, 1)]

create_derived_unit('minute', ['min'], 60, second_cu)
create_derived_unit('hour', ['h'], 3600, second_cu)
create_derived_unit('day', ['d'], 86400, second_cu)
create_derived_unit('degree', ['°'], Math::PI / 180, radian_cu)
create_derived_unit('minute', ['′'], Math::PI / 10800, radian_cu)
create_derived_unit('second', ['″'], Math::PI / 648000, radian_cu)
create_derived_unit('hectare', ['ha'], 10000, meter2_cu)
create_derived_unit('litre', ['l', 'L'], 1 / 1000, meter3_cu)
create_derived_unit('tonne', ['t'], 1000, kilogram_cu)
create_derived_unit('bel', ['B'], 1.1513, neper_cu)
create_derived_unit('decibel', ['dB'], 0.11513, neper_cu)
