require 'singleton'

module Valideizer
  class Holder
    include Singleton

    CALLBACK_TYPE = 'callback'.freeze
    METHOD_TYPE   = 'render_method'.freeze
    RENDER_TYPE   = 'render_block'.freeze

    attr_accessor :valideizers
    attr_accessor :callback_method
    attr_accessor :callback_controller
    attr_accessor :render_method
    attr_accessor :render_controller
    attr_accessor :render_block
    attr_accessor :output_type
    attr_accessor :status

    def initialize
      @valideizers = {}
    end

    def raise_exception
      raise "You've already defined #{@output_type}"
    end
  end
end