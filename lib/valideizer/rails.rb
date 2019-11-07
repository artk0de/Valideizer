require 'valideizer/core'
require 'valideizer/holder'
require 'active_support/concern'

module Valideizer
  module Rails
    extend ActiveSupport::Concern

    def self.included(base)
      base.before_action :valideize!

      base.class_eval do
        class << self
          def valideize(*methods, &options_block)
            methods.each do |method|
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
          end

          def valideizer_callback(method_name)
            holder = Valideizer::Holder.instance
            unless holder.output_type.present?
              # holder.raise_exception
              holder.callback_controller = controller_path
              holder.callback_method = method_name.to_s
              holder.output_type = Valideizer::Holder::CALLBACK_TYPE
            end
          end

          def valideizer_method(method_name)
            holder = Valideizer::Holder.instance
            unless holder.output_type.present?
              holder.render_controller = controller_path
              holder.render_method = method_name.to_s
              holder.output_type = Valideizer::Holder::METHOD_TYPE
            end
          end

          def valideizer_render(status = 400, &block)
            holder = Valideizer::Holder.instance
            unless holder.output_type.present?
              holder.status = status
              holder.render_block = block
              holder.output_type = Valideizer::Holder::RENDER_TYPE
            end
          end
        end
      end
    end

    def valideize!
      valideizer = holder.valideizers[controller_path][action_name] rescue nil
      return if valideizer.nil?

      unless valideizer.valideized?(params)
        case holder.output_type
        when Valideizer::Holder::CALLBACK_TYPE
          redirect_to controller: holder.callback_controller, action: holder.callback_method, errors: valideizer.errors
        when Valideizer::Holder::RENDER_TYPE
          render json: instance_exec(valideizer.errors, &holder.render_block), status: holder.status
        else
          render json: valideizer.errors, status: 400
        end
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