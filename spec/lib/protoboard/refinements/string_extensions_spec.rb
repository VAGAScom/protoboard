# frozen_string_literal: true

RSpec.describe 'Protoboard::Refinements::StringExtensions' do
  using Protoboard::Refinements::StringExtensions

  describe '#convert_special_chars_to_ordinals' do
    subject { some_string.convert_special_chars_to_ordinals }

    context 'when a string contains letters and numbers only' do
      let(:some_string) { 'abc123' }

      it 'returns the same value' do
        is_expected.to eq(some_string)
      end
    end

    context 'when a string contains letters, numbers and a bang' do
      let(:some_string) { 'abc123!' }

      it 'returns the new value with no bang' do
        is_expected.to eq('abc123ORD33')
      end
    end

    context 'when a string contains letters, numbers and a equal signal' do
      let(:some_string) { 'abc123=' }

      it 'returns the new value with no equal' do
        is_expected.to eq('abc123ORD61')
      end
    end

    context 'when a string contains a double equal signals' do
      let(:some_string) { '==' }

      it 'returns the new value with no equal' do
        is_expected.to eq('ORD61ORD61')
      end
    end

    context 'when a string contains a spaceship operator' do
      let(:some_string) { '<=>' }

      it 'returns the new value with no spaceship operator' do
        is_expected.to eq('ORD60ORD61ORD62')
      end
    end
  end
end
