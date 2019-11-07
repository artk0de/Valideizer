require 'time'

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

    def cast_to_time(value)
      Time.parse(value) rescue nil
    end

    def cast_to_time_with_format(value, format)
      Time.strptime(value, format) rescue nil
    end

    def cast_to_boolean(value)
      if %w(1 true).include?(value.to_s.downcase)
        true
      elsif %w(0 false).include?(value.to_s.downcase)
        false
      end
    end
  end
end