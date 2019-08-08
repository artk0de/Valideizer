require 'singleton'

module Valideizer
  class Holder
    include Singleton

    attr_accessor :valideizers
    attr_accessor :callback_method
    attr_accessor :callback_controller

    def initialize
      @valideizers = {}
    end
  end
end