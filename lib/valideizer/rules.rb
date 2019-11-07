require 'json'
require 'time'

module Valideizer
  module Rules
    def validate(value, rule, constraint)
      begin
      case rule
      when :eql           then validate_eql           value, constraint
      when :gt            then validate_gt            value, constraint
      when :gte           then validate_gte           value, constraint
      when :lt            then validate_lt            value, constraint
      when :lte           then validate_lte           value, constraint
      when :ot            then validate_ot            value, constraint
      when :range         then validate_range         value, constraint
      when :enum          then validate_enum          value, constraint
      when :type          then validate_type          value, constraint
      when :array_type    then validate_array_type    value, constraint
      when :custom_type   then validate_custom_type   value, constraint
      when :regexp        then validate_regexp        value, constraint
      when :length        then validate_length        value, constraint
      when :active_record then validate_active_record value, constraint
      when :format        then validate_time_format   value, constraint
      else true
      end
      rescue
        false
      end
    end

    private

    def validate_eql(value, constraint)
      if constraint.is_a? Numeric
        value.to_f == constraint
      else
        value == constraint
      end
    end

    def validate_gt(value, constraint)
      value.to_f > constraint
    end

    def validate_gte(value, constraint)
      value.to_f >= constraint
    end

    def validate_lt(value, constraint)
      value.to_f < constraint
    end

    def validate_lte(value, constraint)
      value.to_f <= constraint
    end

    def validate_ot(value, constraint)
      if constraint.is_a? Numeric
        value.to_f != constraint
      else
        value != constraint
      end
    end

    def validate_range(value, constraint)
      raise 'Must be a range' unless constraint.is_a? Range
      constraint.include? value
    end

    def validate_enum(value, constraint)
      raise 'Must be an array' unless constraint.is_a? Array
      constraint.include? value
    end

    def validate_type(value, constraint)
      if constraint.is_a? Array
        constraint.each { |type| return true if type_check(value, type)}
      else
        type_check(value, constraint)
      end
    end

    def type_check(value, type)
      case type
      when :string   then value.is_a? String
      when :array    then value.is_a? Array
      when :hash     then value.is_a? Hash
      when :integer  then integer_check(value)
      when :float    then float_check(value)
      when :boolean  then boolean_check(value)
      when :json     then json_check(value)
      when :datetime then date_time_check(value)
      else raise "Wrong check type #{value}"
      end
    end

    def date_time_check(value)
      Time.parse(value) rescue return(false)
      true
    end

    def integer_check(value)
      casted_value = value.to_i rescue nil
      if casted_value && (casted_value == 0 && value.to_s.strip == '0' || casted_value != 0)
        true
      else
        false
      end
    end

    def float_check(value)
      casted_value = value.to_f rescue nil
      if casted_value && (casted_value == 0 && value.to_s.strip == '0' || casted_value != 0)
        true
      else
        false
      end
    end

    def boolean_check(value)
      ['0', '1'].include?(value.to_s.strip) || ['true', 'false'].include?(value.to_s.downcase.strip)
    end

    def json_check(value)
      [Hash, Array].include?((JSON.parse value rescue nil).class)
    end

    def validate_array_type(value, constraint)
      if value.is_a? Array
        value.each do  |v|
          if v.is_a?(Array)
            validate_array_type(v, constraint)
          else
            return false unless validate_type(v, constraint)
          end
        end

        true
      else
        false
      end
    end

    def validate_regexp(value, regexp)
      raise 'Must be a string' unless value.is_a? String
      value.match? regexp
    end

    def validate_custom_type(value, constraint)
      value.is_a? constraint
    end

    def validate_length(value, constraint)
      if [Array, Hash, String].include? value.class
        if constraint.is_a? Hash
          raise 'Hash params can not be empty.' if constraint.empty?
          res = true
          res &= value.length >= constraint[:min] unless constraint[:min].nil?
          res &= value.length <= constraint[:max] unless constraint[:max].nil?
          res
        elsif constraint.is_a? Range
          constraint.include? value.length
        else
          raise 'Wrong constraint for :length option. Must be range or hash {min: 0, max: 10}'
        end
      else
        raise 'Must be Array, Hash or String'
      end
    end

    def validate_active_record(value, constraint)
        klass = constraint
        if klass.is_a?(Class) && klass.ancestors.include?(ActiveRecord::Base)
          klass.find_by_id(value).present?
        else
          raise "#{constraint} is not a valid ActiveRecord model"
       end
    end

    def validate_time_format(value, constraint)
      Time.strptime(value, constraint) rescue return(false)
      true
    end
  end
end