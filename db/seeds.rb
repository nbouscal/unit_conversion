# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Unit.create(unit_name: 'meter', symbols: ['m'])
Unit.create(unit_name: 'second', symbols: ['s'])
Unit.create(unit_name: 'kilogram', symbols: ['kg'])
Unit.create(unit_name: 'ampere', symbols: ['Ω'])
Unit.create(unit_name: 'candela', symbols: ['cd'])
Unit.create(unit_name: 'kelvin', symbols: ['K'])
Unit.create(unit_name: 'mole', symbols: ['mol'])
