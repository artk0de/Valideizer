require_relative 'spec_helper.rb'

RSpec.describe Valideizer::Core do
  let(:valideizer)   { Valideizer::Core.new }
  let(:valideizer_2) { Valideizer::Core.new }
  let(:valideizer_r) { Valideizer::Core.new }

  describe '#valideize?' do
    before do
      valideizer.add_rule(:a, type: :integer, gt: 0)
      valideizer.add_rule(:b, type: :string, length: 0..10)
      valideizer.add_rule(:c, type: :json)
      valideizer.add_rule(:d, array_type: :integer)
      valideizer.add_rule(:e, enum: [1, 2, 3])
    end

    it 'Validates params by rules' do
      params = {
        a: 1,
        b: 'five',
        c: '{"a": 1}',
        d: [1, 2, 3],
        e: 1
      }

      expect(valideizer.valideized? params).to be true

      params = {
        a: 1,
        b: 'fivesixseveneightnine',
        c: '{"a": 1}',
        d: [1, 2, 3],
        e: 1
      }

      expect(valideizer.valideized? params).to be false
    end

    it 'Returns errors ' do
      params = {
        a: 1,
        b: 'fivesixseveneightnine',
        c: '{"a": 1}',
        d: [1, 2, 3],
        e: 1
      }

      valideizer.valideized? params

      expect(valideizer.errors.count).to eq(1)

      params = {
        a: -34,
        b: 'fivesixseveneightnine',
        c: 'some',
        d: [1, 2, 3, "asd"],
        e: 4
      }

      valideizer.valideized? params
      expect(valideizer.errors.count).to eq(5)
    end

    it 'Setup defaults' do
      valideizer_2.add_rule(:a, type: :integer, default: 10)
      valideizer_2.add_rule(:b, type: :string, default: 'default')

      params = {
        a: nil,
        b: nil
      }

      valideizer_2.valideized? params

      expect(params).to eq(a: 10, b: 'default')
    end

    it 'Recasts params' do
      valideizer_r.add_rule(:a, type: :integer)
      valideizer_r.add_rule(:b, type: :json)
      valideizer_r.add_rule(:c, type: :bool)

      params = {
        a: "1",
        b: "[1,2,3]",
        c: "false"
      }
      valideizer_r.valideized? params
      expect(params).to eq(a: 1, b: [1,2,3], c: false)
    end
  end
end