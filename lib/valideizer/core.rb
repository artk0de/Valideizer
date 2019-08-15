require 'valideizer/rules'
require 'valideizer/error_printer'
require 'valideizer/caster'

module Valideizer
  class Core
    include Valideizer::Rules
    include Valideizer::Caster
    include Valideizer::ErrorPrinter

    def initialize
      @rules = {}
      reinit_errrors
    end

    def add_rule(param, *rules)
      @rules[param.to_s] = rules[0]
    end

    alias valideize add_rule

    def valideized?(params)
      pre_process params

      params.each do |param, value|
        next unless nil_check(param, value)
        @rules[param.to_s].each do |type, constraint|
          begin
            push_error(param, value, type, constraint) unless validate(value, type, constraint)
          rescue ArgumentError => ex
            puts ex
          end
        end if @rules.include? param.to_s
      end

      if @errors.empty?
        post_process params
        true
      else
        false
      end
    end

    def errors
      build_error_messages
      @error_messages
    end

    private

    def pre_process(params)
      reinit_errrors
      setup_defaults params
    end

    def reinit_errrors
      @errors = {}
      @error_messages = []
    end

    def push_error(param, value, type, constraint)
      @errors[param] = [] unless @errors.member? param
      @errors[param].push(type: type, value: value, constraint: constraint)
    end

    def setup_defaults(params)
      @rules.each do |param, rules|
        default_rule = rules.find { |r, _c| r == :default }
        can_be_defaulted = default_rule && (params[param].nil? || params[param]&.empty?)

        if params.include? param.to_sym
          param = param.to_sym
          params[param] = default_rule.last if default_rule && (params[param].nil? || params[param]&.empty?)
        elsif params.include? param.to_s
          param = param.to_s
          params[param] = default_rule.last if default_rule && (params[param].nil? || params[param]&.empty?)
        else
          params.merge!(param => default_rule.last) if can_be_defaulted
        end
      end
    end

    def nil_check(param, value)
      if !value.nil? || value.nil? && has_allow_nil_rule(param)
        true
      else
        push_error(param, :nil, nil, nil)
        false
      end
    end

    def has_allow_nil_rule(param)
      nil_rule = @rules[param.to_s]&.find { |r, _c| r == :nil }
      nil_rule.nil? ? false : nil_rule.last
    end

    def post_process(params)
      @rules.each do |key, rules|
        next if params[key.to_s].nil? && params[key.to_sym].nil?
        key = key.to_sym if params.include? key.to_sym

        type_rule = rules.find { |r, _c| r == :type }
        recast(params, key, type_rule.last) if type_rule

        regexp_rule = rules.find { |r, _c| r == :regexp }
        regexp_groups_substitution(params, key, regexp_rule.last) if regexp_rule
      end
    end


    def recast(params, key, type)
      value = params[key]
      params[key] = case type
                    when :json    then cast_from_json value
                    when :bool    then cast_to_bool value
                    when :float   then cast_to_float value
                    when :integer then cast_to_integer value
                    else value
                    end
    end

    def regexp_groups_substitution(params, key, regexp)
      value = params[key]

      matched = value.match regexp
      return if matched.nil?

      params[key] = if matched.named_captures.any?
                      matched.named_captures
                    elsif matched.captures.count > 1
                      matched.captures
                    elsif matched.captures.count == 1
                      matched.captures[0]
                    end
    end

    def build_error_messages
      @error_messages = print_errors
    end
  end
end