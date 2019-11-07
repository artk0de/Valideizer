module Valideizer
  module ErrorPrinter
    PREFIX = "Validation error:".freeze

    protected

    def print_errors
      @errors.map { |param_name, errors| errors.map { |error| { message: print_error(param_name, error) }}}.flatten
    end

    private

    def print_option(type, constraint, value)
      case type
      when :eql           then "Should be equal to #{constraint}."
      when :gt            then "Should be greater than #{constraint}."
      when :gte           then "Should be greater than or equal to #{constraint}."
      when :lt            then "Should be less than #{constraint}."
      when :lte           then "Should be less than or equal to #{constraint}."
      when :ot            then "Should be other than #{constraint}."
      when :range         then "Out of range. Should be in #{constraint.to_s} range."
      when :enum          then "Out of enum. Possible values #{constraint.to_s}."
      when :type          then "Should be #{constraint} type. Current type: `#{value.class}`."
      when :array_type    then "Should be array of #{constraint} type."
      when :custom_type   then "Should be #{constraint} type."
      when :regexp        then "Couldn't be matched by #{constraint}."
      when :length        then "Length must be #{constraint}. Current value: `#{value}`, length: #{value.length}."
      when :active_record then "Couldn't find #{constraint} with ID=#{value}."
      when :null          then "Can not be nil or empty."
      when :format        then "Don't match current time pattern #{constraint}"
      else ''
      end
    end

    def print_postfix(type, value)
      "Current value: `#{value}`." unless %i[type array_type custom_type active_record length].include?(type)
    end

    # Validation error: :some param. Should be greater or equal than 200. Current value (100).

    def print_error(param_name, error)
      message = ""
      message << PREFIX
      message << "`#{param_name}`" + "\s" + "param."
      message << "\s"
      message << print_option(error[:type], error[:constraint], error[:value])
      message << "\s"
      message << (print_postfix(error[:type], error[:value]) || '')

      message
    end
  end
end