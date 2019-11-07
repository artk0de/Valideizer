module Valideizer
  module RulesChecker
    RULES_EXCEPTIONS = %i[null default]

    RULES_W_FRIENDLY = {
      eql:           %i[type default null],
      ot:            %i[type default null],
      gt:            %i[type default null lt lte],
      gte:           %i[type default null lt lte],
      lt:            %i[type default null gt gte],
      lte:           %i[type default null gt gte],
      range:         %i[type default null],
      enum:          %i[type default null],
      type:          %i[default null eql ot gt gte lt lte range enum regexp length format],
      array_type:    %i[default null length],
      custom_type:   %i[default null],
      active_record: %i[default null],
      length:        %i[type array],
      regexp:        %i[type default null],
      null:          %i[all],
      default:       %i[all],
      format:        %i[type default null],
    }.freeze

    VALID_TYPE_RULES = {
      integer:  %i[eql gt gte lt lte ot range enum null default],
      float:    %i[eql gt gte lt lte ot range enum null default],
      string:   %i[enum length eql ot regexp null default],
      datetime: %i[null default format],
      json:     %i[null default],
      boolean:  %i[null default],
      hash:     %i[null default length],
      array:    %i[null default length],
    }.freeze

    def check_rule_set(rules)
      errors = []
      check_wrong_rules(rules, errors)
      check_conflicting_rules(rules, errors)
      check_type_rules(rules, errors)

      raise errors.join('. ') if errors.any?
    end

    private

    def check_wrong_rules(rules, errors)
      rules.each_key do |rule_name|
        unless RULES_W_FRIENDLY.include? rule_name
          errors << "Wrong rule: :#{rule_name}"
          rules.delete rule_name
        end
      end

    end

    def check_conflicting_rules(rules, errors)
      rules.each_key do |rule_name|
        incompatibles = []
        next if RULES_EXCEPTIONS.include?(rule_name)
        rules.each_key do |check_rule|
          next if rule_name == check_rule || RULES_EXCEPTIONS.include?(check_rule)
          incompatibles << check_rule unless RULES_W_FRIENDLY[rule_name].include?(check_rule)
        end
        if incompatibles.any?
          errors << ":#{rule_name} incompatible with #{incompatibles.join(', ')} rules"
        end
      end
    end

    def check_type_rules(rules, errors)
      return unless rules.include?(:type)

      unless VALID_TYPE_RULES.include? rules[:type]
        errors << ":#{rules[:type]} isn't avalaible type"
        return
      end

      incompatibles = []
      rules.each_key do |rule_name|
        next if rule_name == :type || RULES_EXCEPTIONS.include?(rule_name)
        incompatibles << rule_name unless VALID_TYPE_RULES[rules[:type]].include? rule_name
      end

      if incompatibles.any?
        errors << "Type :#{rules[:type]} is incompatible with #{incompatibles.join(", ")} parameters"
      end
    end
  end
end