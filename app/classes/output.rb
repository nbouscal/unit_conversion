class Output

  attr_accessor :unit_name, :multiplication_factor, :linear_shift, :output_value

  # add_unit :: Output -> Conversion -> Output
  def add_unit(conversion)
    return self
  end

end
