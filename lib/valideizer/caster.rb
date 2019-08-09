module Valideizer
  module Caster
    def cast_from_json(value)
      JSON.parse(value) rescue nil
    end

    def cast_to_integer(value)
      value.to_i rescue nil
    end

    def cast_to_float(value)
      value.to_f rescue nil
    end

    def cast_to_bool(value)
      return false if ['0', 'false'].include? value.to_s.downcase
      return true  if ['1', 'true'].include? value.to_s.downcase
    end
  end
end