require 'valideizer/core'
require 'valideizer/holder'
require 'active_support/concern'

module Valideizer
  module Rails
    extend ActiveSupport::Concern

    def self.included(base)
      base.before_action :valideize!

      base.class_eval do
        def self.valideize(method, &options_block)
          method = method.to_s
          holder = Valideizer::Holder.instance
          holder.valideizers[controller_path] = {} if holder.valideizers[controller_path].nil?

          # raise "Action #{method} is not defined in #{controller_name}" unless action_methods.include? method.to_s

          if holder.valideizers[controller_path][method].nil?
            holder.valideizers[controller_path][method] = Valideizer::Core.new
          end

          valideizer = holder.valideizers[controller_path][method]
          valideizer.instance_eval(&options_block)
        end

        def self.valideizer_callback(method_name)
          holder = Valideizer::Holder.instance
          unless holder.callback_controller.present?
            holder.callback_controller = controller_path
            holder.callback_method = method_name.to_s
          end
        end
      end
    end

    def valideize!
      valideizer = holder.valideizers[controller_path][action_name] rescue nil
      return unless valideizer

      unless valideizer.nil? || holder.callback_method.nil?
        redirect_to(controller: holder.callback_controller,
          action: holder.callback_method, errors: valideizer.errors) unless valideizer.valideized?(params)
      end
    end

    def valideized?(params)
      holder.valideizers[controller_path][action_name].valideized?(params)
    end

    def valideizer_errors
      holder.valideizers[controller_path][action_name].errors
    end

    private

    def holder
      Valideizer::Holder.instance
    end
  end
end