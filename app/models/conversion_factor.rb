class ConversionFactor < ActiveRecord::Base

  belongs_to :unit

  # serialize :compound_unit, Marshal

  # def unit
  #   compound_unit.map { |h| ConversionFactor.cunit_from_hash(h) }
  # end

  # def unit=

  # end

  def unit
    Marshal.load(self.compound_unit)
  end

  def unit=(obj)
    self.compound_unit = Marshal.dump(obj)
  end

  def output (output_value)
    Unit::Output.new(Unit.print_unit(unit), multiplication_factor, linear_shift, output_value)
  end

  # combine_factors :: ConversionFactor -> ConversionFactor -> ConversionFactor
  def combine_factors (factor2)
    cu1 = unit
    cu2 = factor2.unit
    cu = Unit.simplify(cu1 + cu2)
    mf = Rational(multiplication_factor) * Rational(factor2.multiplication_factor)
    ls = Rational(linear_shift) + Rational(factor2.linear_shift)

    new_factor = ConversionFactor.new(multiplication_factor: mf, linear_shift: ls)
    new_factor.compound_unit = cu

    return new_factor
  end

  # convert :: Rational -> Rational
  def convert (input_value)
    Rational(input_value) * Rational(multiplication_factor) + Rational(linear_shift)
  end

  def self.cunit_from_hash (hash)
    unit = Unit.find(hash['unit']['id'])
    exp = hash['exponent']
    Unit::CUnit.new(unit, exp)
  end

end
