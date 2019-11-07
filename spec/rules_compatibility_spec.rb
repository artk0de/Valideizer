require_relative 'spec_helper.rb'
require 'valideizer/rules'

RSpec.describe Valideizer::RulesChecker do
  describe 'Compatibilities' do
    let(:valideizer) { Valideizer::Core.new }

    it 'Should adds rules.' do
      valideizer.valideize :a, type: :integer, gt: 0, lt: 100
      valideizer.valideize :b, type: :string, enum: ['one', 'two', 'three'], null: true
      valideizer.valideize :c, type: :datetime, format: '%Y', default: Time.now.strftime('%Y')

      expect(valideizer.rules.keys).to eq(['a', 'b', 'c'])
    end
  end

  describe 'Incompatibilites' do
    let(:valideizer) { Valideizer::Core.new }

    it 'Should not adds rules' do
      expect { valideizer.valideize :a, type: :integer, format: '%Y', length: 0..10 }.to raise_exception
      expect { valideizer.valideize :b, type: :datetime, enum: [1,2,3] }.to raise_exception
      expect { valideizer.valideize :c, type: :xyu, gt: 100, regexp: /aA/, something: '' }.to raise_exception
    end
  end
end