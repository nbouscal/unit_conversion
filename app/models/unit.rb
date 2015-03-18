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
    #     compound_unit :: CompoundUnit -- should contain inverse of the
    #                                   -- original unit???
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
      parse_unit('meters/second')
    end

    # private

    CUnit = Struct.new(:unit, :exponent)

    # Unit.parse_unit :: String -> CompoundUnit
    def parse_unit(unit_name)
      tokens = tokenize(unit_name)
      compound_unit = parse(tokens)
      simplified_unit = simplify(compound_unit)
      return simplified_unit
    end

    # Unit.tokenize :: String -> [String]
    def tokenize(unit_name)
      unit_name = unit_name.gsub('/', ' / ')
      unit_name = unit_name.gsub('*', ' * ')
      tokens = unit_name.split()
      return tokens
    end

    # Unit.parse :: [String] -> CompoundUnit
    def parse(tokens)
      tokens.delete_if { |t| t == '*' } # multiplication is the default
      tokens.map! do |token|
        # singularize, but make sure not to replace seconds with nil
        token == 's' ? token : token.singularize
      end


      division = tokens.index('/')
      if division.nil?
        numerator = tokens
        denominator = []
      else
        numerator = tokens[0...division]
        denominator = tokens[division+1..-1]
      end
    end

    # Unit.simplify :: CompoundUnit -> CompoundUnit
    # This method will take a compound unit and combine any duplicated units
    # by combining their exponents. For example, it will convert
    # meter*meter/second into meter^2/second.
    def simplify(compound_unit)
      return [] if compound_unit.nil?

      simplified_unit = []

      compound_unit.compact!.sort_by!(&:unit)

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

  end

end
