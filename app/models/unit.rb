class Unit < ActiveRecord::Base

  class ConversionFactor
    attr_accessor :compound_unit, :multiplication_factor, :linear_shift

    # combine_factors:: ConversionFactor -> ConversionFactor -> ConversionFactor
    def combine_factors (factor2)
      compound_unit = Unit.simplify(self.compound_unit.concat(factor2.compound_unit))
      multiplication_factor = self.multiplication_factor * factor2.multiplication_factor
      linear_shift = self.linear_shift + factor2.linear_shift

      new_factor = ConversionFactor.new(
        compound_unit,
        multiplication_factor,
        linear_shift
      )

      return new_factor
    end
  end

  class << self

    # data SimpleUnit = SimpleUnit {
    #     unit_name :: String
    #   , symbols :: [String]
    #   , to_SI :: ConversionFactor
    #   }
    #
    # data CUnit = CUnit {
    #     unit :: Unit
    #   , exponent :: Fixnum
    #   }
    # type CompoundUnit = [CUnit]
    #
    # data Quantity = Quantity {
    #     amount :: Rational
    #   , compound_unit :: CompoundUnit
    #   }
    #
    # data ConversionFactor = ConversionFactor {
    #     compound_unit :: CompoundUnit
    #       ^-- should contain inverse of the original unit???
    #   , multiplication_factor :: Rational
    #   , linear_shift :: Rational
    #   }

    # data Output = Output {
    #     unit_name :: String
    #   , multiplication_factor :: Rational
    #   , linear_shift :: Rational
    #   , output_value :: OutputValue
    #   }
    #
    # data InputValue
    #   = InputScalar Rational -- Numeric
    #   | InputVector [Rational] -- Array
    #   | NoInputValue -- nil
    #
    # data OutputValue
    #   = OutputScalar Rational -- Numeric
    #   | OutputVector [Rational] -- Array
    #   | NoOutputValue -- nil
    #
    # Unit.to_SI :: (String, InputValue) -> Output
    def to_SI(input_unit_name, input_value = nil)

      # input_units :: CompoundUnit
      input_compound_unit = self.parse_unit(input_unit_name)

      # converted_units :: [ConversionFactor]
      converted_units = input_units.map(&:to_SI)

      # conversion_factor :: ConversionFactor
      conversion_factor = converted_units.reduce(:combine_factors)

      #result :: Output
      result = conversion_factor.convert(input_compound_unit)

      case input_value
        when NilClass
          #
        when Numeric
          #
        when Array
          #
      end

      return result

    end

    def test
      print_unit(parse_unit('meters * kg/second * s'))
    end

    private

    CUnit = Struct.new(:unit, :exponent)

    # Unit.parse_unit :: String -> CompoundUnit
    def parse_unit(unit_name)
      tokens = tokenize(unit_name)
      compound_unit = parse(tokens)
      simplified_unit = simplify(compound_unit)
      return simplified_unit
    end

    # Unit.tokenize :: String -> [String]
    # Takes a string unit name and turns it into a list of tokens,
    # including * and /
    def tokenize(unit_name)
      unit_name = unit_name.gsub('/', ' / ')
      unit_name = unit_name.gsub('*', ' * ')
      tokens = unit_name.split()
      return tokens
    end

    # Unit.parse :: [String] -> CompoundUnit
    # Takes a list of tokens, including * and /, and turns them into a list of
    # CUnits containing the appropriate Units. Raises an error if it can't
    # find one of the units
    def parse(tokens)
      tokens.delete_if { |t| t == '*' } # multiplication is the default
      tokens.map! do |token|
        # singularize, but make sure not to replace seconds with nil
        token == 's' ? token : token.singularize
      end

      division = tokens.index('/')
      tokens.delete('/')

      units = tokens.map do |token|
        unit = Unit.find_by unit_name: token
        if unit.nil?
          unit = Unit.where('? = ANY(symbols)', token).first
        end
        if unit.nil?
          raise NoSuchUnit
        end
        CUnit.new(unit, 1)
      end

      unless division.nil?
        numerator = units[0...division]
        denominator = units[division..-1].map do |u|
          u.exponent *= -1
          u
        end

        units == numerator.concat(denominator)
      end

      return units
    end

    # Unit.simplify :: CompoundUnit -> CompoundUnit
    # Takes a compound unit and combines any duplicated units
    # by combining their exponents. For example, converts
    # meter*meter/second into meter^2/second.
    def simplify(compound_unit)
      return [] if compound_unit.nil?

      simplified_unit = []

      compound_unit = compound_unit.compact.sort_by!(&:unit)

      compound_unit.each do |cunit|
        last = simplified_unit.last
        unless last.nil?
          if last.unit == cunit.unit
            last.exponent += cunit.exponent
          else
            simplified_unit << cunit.dup
          end
        else
          simplified_unit << cunit.dup
        end
      end

      return simplified_unit
    end

    # Unit.print_unit :: CompoundUnit -> String
    def print_unit(compound_unit)
      compound_unit.reduce('') do |memo, obj|
        unit = obj.unit.symbols.first
        exp = obj.exponent
        if exp.abs > 1
          unit = unit + '^' + exp.to_s
        end
        if memo == ''
          unit
        else
          memo + ' * ' + unit
        end
      end
    end

  end

end
