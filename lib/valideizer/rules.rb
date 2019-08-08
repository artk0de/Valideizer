require 'json'

module Valideizer
  module Rules
    RULES = %i[
      eql
      gt
      gte
      lt
      lte
      ot
      range
      enum
      type
      array_type
      custom_type
      active_record
      length
      regexp
      nil
      default
    ]

    def validate(param, rule, constraint)
      begin
      case rule
      when :eql           then validate_eql           param, constraint
      when :gt            then validate_gt            param, constraint
      when :gte           then validate_gte           param, constraint
      when :lt            then validate_lt            param, constraint
      when :lte           then validate_lte           param, constraint
      when :ot            then validate_ot            param, constraint
      when :range         then validate_range         param, constraint
      when :enum          then validate_enum          param, constraint
      when :type          then validate_type          param, constraint
      when :array_type    then validate_array_type    param, constraint
      when :custom_type   then validate_custom_type   param, constraint
      when :regexp        then validate_regexp        param, constraint
      when :length        then validate_length        param, constraint
      when :active_record then validate_active_record param, constraint
      else true
      end
      rescue
        false
      end
    end

    private

    def validate_eql(param, constraint)
      param == constraint
    end

    def validate_gt(param, constraint)
      param > constraint
    end

    def validate_gte(param, constraint)
      param >= constraint
    end

    def validate_lt(param, constraint)
      param < constraint
    end

    def validate_lte(param, constraint)
      param <= constraint
    end

    def validate_ot(param, constraint)
      param != constraint
    end

    def validate_range(param, constraint)
      raise 'Must be a range' unless constraint.is_a? Range
      constraint.include? param
    end

    def validate_enum(param, constraint)
      raise 'Must be an array' unless constraint.is_a? Array
      constraint.include? param
    end

    def validate_type(param, constraint)
      if constraint.is_a? Array
        constraint.each { |type| return true if type_check(param, type)}
      else
        type_check(param, constraint)
      end
    end

    def type_check(param, type)
      case type
      when :integer then param.is_a? Integer
      when :float   then param.is_a? Float
      when :string  then param.is_a? String
      when :array   then param.is_a? Array
      when :hash    then param.is_a? Hash
      when :bool    then bool_check(param)
      when :json    then json_check(param)
      else raise "Wrong check type #{param}"
      end
    end

    def bool_check(param)
      [0, 1].include?(param) || ['true', 'false'].include?(param.to_s.downcase)
    end

    def json_check(param)
      [Hash, Array].include?((JSON.parse param rescue nil).class)
    end

    def validate_array_type(param, constraint)
      if param.is_a? Array
        param.each do  |v|
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

    def validate_regexp(param, regexp)
      raise 'Must be a string' unless param.is_a? String
      param.match? regexp
    end

    def validate_custom_type(param, constraint)
      param.is_a? constraint
    end

    def validate_length(param, constraint)
      if [Array, Hash, String].include? param.class
        if constraint.is_a? Hash
          raise 'Hash params can not be empty.' if constraint.empty?
          res = true
          res &= param.length >= constraint[:min] unless constraint[:min].nil?
          res &= param.length <= constraint[:max] unless constraint[:max].nil?
          res
        elsif constraint.is_a? Range
          constraint.include? param.length
        else
          raise 'Wrong constraint for :length option. Must be range or hash {min: 0, max: 10}'
        end
      else
        raise 'Must be Array, Hash or String'
      end
    end

    def validate_active_record(param, constraint)
        klass = constraint
        if klass.is_a? ActiveModel || (klass = constraint.to_s.constantize).is_a?(ActiveModel)
          klass.find_by_id(param).present?
        else
          raise "#{constraint} is not a valid ActiveRecord model"
       end
    end
  end
end