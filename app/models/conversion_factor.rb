class ConversionFactor < ActiveRecord::Base

  belongs_to :unit

  def unit
    Marshal.load(Base64.decode64(self.compound_unit))
  end

  def unit=(obj)
    self.compound_unit = Base64.encode64(Marshal.dump(obj))
  end

  def exponentiate (exponent)
    # apply the exponent to the multiplication factor
    mf = multiplication_factor
    self.multiplication_factor = mf ** exponent

    # apply the exponent to each of the new units
    new_unit = self.unit.dup
    new_unit.map! do |cu|
      cu.exponent *= exponent
      cu
    end

    self.unit = new_unit
    return self
  end

  def output (output_value)
    Unit::Output.new(
      Unit.print_unit(unit),
      multiplication_factor,
      linear_shift,
      output_value
    )
  end

  # combine_factors :: ConversionFactor -> ConversionFactor -> ConversionFactor
  def combine_factors (factor2)
    cu1 = unit
    cu2 = factor2.unit
    cu = Unit.simplify(cu1 + cu2)
    mf = multiplication_factor * factor2.multiplication_factor
    ls = linear_shift + factor2.linear_shift

    new_factor = ConversionFactor.new(
      multiplication_factor: mf,
      linear_shift: ls
    )
    new_factor.unit = cu

    return new_factor
  end

  # convert :: Float -> Float
  def convert (input_value)
    input_value.to_f * multiplication_factor + linear_shift
  end

end
