require_relative 'spec_helper.rb'
require 'valideizer/rules'

RSpec.describe Valideizer::Rules do
  describe 'Validations' do

    let(:valideizer) { Class.new { include Valideizer::Rules }.new }

    it 'Tests :eql' do
      expect(valideizer.validate(100, :eql, 100)).to be_truthy
      expect(valideizer.validate(100, :eql, 101)).to be_falsey
      expect(valideizer.validate("caseinsesitive", :eql, "caseinsesitive")).to be_truthy
      expect(valideizer.validate("casesensitive", :eql, "caseSensitive")).to be_falsey
    end

    it 'Tests :gt' do
      expect(valideizer.validate(100, :gt, 99)).to be_truthy
      expect(valideizer.validate(100, :gt, 101)).to be_falsey
    end

    it 'Tests :gte' do
      expect(valideizer.validate(100, :gte, 99)).to be_truthy
      expect(valideizer.validate(100, :gte, 100)).to be_truthy
      expect(valideizer.validate(100, :gte, 101)).to be_falsey
    end

    it 'Tests :lt' do
      expect(valideizer.validate(100, :lt, 99)).to be_falsey
      expect(valideizer.validate(100, :lt, 100)).to be_falsey
      expect(valideizer.validate(99, :lt, 100)).to be_truthy
    end

    it 'Tests :lte' do
      expect(valideizer.validate(100, :lte, 99)).to be_falsey
      expect(valideizer.validate(100, :lte, 100)).to be_truthy
      expect(valideizer.validate(99, :lte, 100)).to be_truthy
    end

    it 'Tests :ot' do
      expect(valideizer.validate(100, :ot, 100)).to be_falsey
      expect(valideizer.validate(101, :ot, 100)).to be_truthy
      expect(valideizer.validate(99, :ot, 100)).to be_truthy
    end

    it 'Tests :range' do
      expect(valideizer.validate(100, :range, 99..100)).to be_truthy
      expect(valideizer.validate(100, :range, 99...101)).to be_truthy
      expect(valideizer.validate(100, :range, 99...100)).to be_falsey
    end

    it 'Tests :enum' do
      expect(valideizer.validate(100, :enum, [99, 100])).to be_truthy
      expect(valideizer.validate(100, :enum, [99, 101])).to be_falsey
      expect(valideizer.validate(['a', 'b'], :enum, ['a', 'b', 'c'])).to be_truthy
      expect(valideizer.validate(['a', 'd'], :enum, ['a', 'b', 'c'])).to be_falsey
    end

    it 'Tests :type' do
      expect(valideizer.validate(100, :type, :integer)).to be_truthy
      expect(valideizer.validate('100', :type, [:integer, :string])).to be_truthy
      expect(valideizer.validate('100', :type, :string)).to be_truthy
      expect(valideizer.validate(100.01, :type, :string)).to be_falsey
      expect(valideizer.validate('{"a": 1}', :type, :string)).to be_truthy
    end

    it 'Tests :array_type' do
      expect(valideizer.validate([100, 101], :array_type, :integer)).to be_truthy
      expect(valideizer.validate([100, 101], :array_type, :string)).to be_falsey
      expect(valideizer.validate([100, '101'], :array_type, [:integer, :string])).to be_truthy
      expect(valideizer.validate([[100, 99], [200, 99]], :array_type, :integer)).to be_truthy
    end

    it 'Tests :length' do
      expect(valideizer.validate('five', :length, 0..4)).to be_truthy
      expect(valideizer.validate('five', :length, {min: 4, max: 5})).to be_truthy
      expect(valideizer.validate('five', :length, {max: 3})).to be_falsey
    end

    it 'Tests :regexp' do
      expect(valideizer.validate('abcd', :regexp, /[a-zA-z]{4}/)).to be_truthy
      expect(valideizer.validate('1bcd', :regexp, /[a-zA-z]{4}/)).to be_falsey
    end

    it 'Tests :dates' do
      expect(valideizer.validate('23.05.1995', :format, '%d.%m.%Y')).to be_truthy
      expect(valideizer.validate('23.05.1995T09:00:00', :format, '%d.%m.%YT%H:%M:%s')).to be_truthy
      expect(valideizer.validate('05.23.1995T09:03:00', :format, '%d.%m.%YT%H:%M:%s')).to be_falsey

      expect(valideizer.validate('23.05.1995', :type, :datetime)).to be_truthy
      expect(valideizer.validate('Not a date', :type, :datetime)).to be_falsey
    end

    it 'Tests :uniq' do
      expect(valideizer.validate(%w(a b), :unique, true)).to be_truthy
      expect(valideizer.validate(%w(a a), :unique, true)).to be_falsey
      expect(valideizer.validate(%w(a a), :unique, false)).to be_truthy
    end
  end
end