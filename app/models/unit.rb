class Unit < ActiveRecord::Base

  has_one :conversion_factor

  CUnit = Struct.new(:unit, :exponent)
  Output = Struct.new(:unit_name, :multiplication_factor, :linear_shift, :output_value)

  class << self

    # Unit.to_SI :: (String, InputValue) -> Output
    def to_SI(input_unit_name, input_value = nil)

      # input_compound_unit :: CompoundUnit
      input_compound_unit = self.parse_unit(input_unit_name)

      # unit_conversions :: [ConversionFactor]
      unit_conversions = input_compound_unit.map do |cu|
        cf = cu.unit.conversion_factor
        cf.exponentiate(cu.exponent)
      end

      # cf :: ConversionFactor
      cf = unit_conversions.reduce(:combine_factors)


      case input_value
        when String
          if (num = Float(input_value) rescue nil)
            output_value = cf.convert(num)
          end
        when Numeric
          output_value = cf.convert(input_value.to_f)
        when Array
          output_value = input_value.map do |iv|
            cf.convert(iv.to_f)
          end
      end

      output = cf.output(output_value)

      return output

    end

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
        # singularize, but make sure not to replace seconds with ''
        token == 's' ? token : token.singularize
      end

      # only supports one instance of division
      division = tokens.index('/')
      tokens.delete('/')

      # units :: [CUnit]
      units = tokens.map do |token|
        unit = Unit.find_by unit_name: token
        if unit.nil?
          unit = Unit.where('? = ANY(symbols)', token).first
        end
        if unit.nil?
          raise "No unit found named #{token}."
        end
        CUnit.new(unit, 1)
      end

      unless division.nil?
        numerator = units[0...division]
        denominator = units[division..-1].map do |u|
          u.exponent *= -1
          u
        end

        units == numerator + denominator
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

      compound_unit.each do |u|
        last = simplified_unit.last
        if !last.nil? && last.unit == u.unit
            last.exponent += u.exponent
        else
          simplified_unit << u.dup
        end
      end

      simplified_unit.map! do |u|
        u.exponent == 0 ? nil : u
      end.compact!

      return simplified_unit
    end

    # Unit.print_unit :: CompoundUnit -> String
    # Print out the unit name, preferring to use negative exponents if there
    # is no numerator, but a division sign if there is a numerator and a
    # denominator.
    def print_unit(compound_unit)
      num = compound_unit.select { |u| u.exponent > 0 }
      den = compound_unit.select { |u| u.exponent < 0 }

      def aux (cu)
        cu.reduce('') do |memo, obj|
          unit = obj.unit.symbols.first
          exp = obj.exponent
          if exp != 1
            unit = unit + '^' + exp.to_s
          end
          if memo == ''
            unit
          else
            memo + ' * ' + unit
          end
        end
      end

      if den == []
        aux(num)
      elsif num == []
        aux(den)
      else
        den = den.map { |u| u.exponent *= -1; u }
        aux(num) + '/' + aux(den)
      end
    end

  end

end
