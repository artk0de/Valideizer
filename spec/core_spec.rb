require_relative 'spec_helper.rb'

RSpec.describe Valideizer::Core do
  let(:valideizer)                { Valideizer::Core.new }
  let(:valideizer_2)              { Valideizer::Core.new }
  let(:valideizer_r)              { Valideizer::Core.new }
  let(:valideizer_3)              { Valideizer::Core.new }
  let(:valideizer_date)           { Valideizer::Core.new }
  let(:valideizer_date_formatted) { Valideizer::Core.new }

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
      valideizer_r.add_rule(:c, type: :boolean)

      params = {
        a: "1",
        b: "[1,2,3]",
        c: "false"
      }
      valideizer_r.valideized? params
      expect(params).to eq(a: 1, b: [1,2,3], c: false)
    end

    it 'Validates and recasts datetime' do
      valideizer_r.clean!
      valideizer_r.add_rule(:time, type: :datetime)
      valideizer_r.add_rule(:time_w_format, datetime: '%d.%m.%Y')

      params = {
        time: '23.05.1995',
        time_w_format: '23.05.1995'
      }

      expect(valideizer_r.valideized?(params)).to be(true)
      expect(params[:time].class).to be(Time)
      expect(params[:time_w_format].class).to be(Time)
    end

    it 'Substitute matched regexep params' do
      group_regexp = /(\d{1,2}.\d{1,2}.\d{4})-(\d{1,2}.\d{1,2}.\d{4})/
      named_regexp = /(?<start_date>\d{1,2}.\d{1,2}.\d{4})-(?<end_date>\d{1,2}.\d{1,2}.\d{4})/
      single_capture = /(\d{1,2}.\d{1,2}.\d{4})-\d{1,2}.\d{1,2}.\d{4}/

      valideizer_3.add_rule :group, regexp: group_regexp
      valideizer_3.add_rule :named_group, regexp: named_regexp
      valideizer_3.add_rule :single_capture, regexp: single_capture

      params = {
        group: "11.09.2001-11.09.2017",
        named_group: "11.09.2001-11.09.2017",
        single_capture: "11.09.2001-11.09.2017"
      }

      valideizer_3.valideized? params

      expect(params[:group][0]).to eq "11.09.2001"
      expect(params[:group][1]).to eq "11.09.2017"

      expect(params[:named_group]['start_date']).to eq "11.09.2001"
      expect(params[:named_group]['end_date']).to eq "11.09.2017"

      expect(params[:single_capture]).to eq "11.09.2001"
    end

    it 'Validates unformatted date' do
      valideizer_date.add_rule :date, type: :datetime
      params = { date: '23.05.1995' }

      expect(valideizer_date.valideized?(params)).to be true
    end

    it 'Validates formatted date' do
      valideizer_date.add_rule :date, type: :datetime, format: '%d.%m.%YT%H:%M:%s'

      expect(valideizer_date.valideized?({ date: '23.05.1995T09:03:00' })).to be_truthy
      expect(valideizer_date.valideized?({ date: '05.23.1995T09:03:00' })).to be_falsey
    end
  end
end