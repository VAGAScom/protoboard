RSpec.describe Protoboard::Adapters::StoplightAdapter do
  describe '.run_circuit' do
    subject(:run_circuit) { Protoboard.config.adapter.run_circuit(circuit) { some_object.some_method } }

    let(:circuit) do
      Protoboard::Circuit.new(
        name: 'my_cool_service#some_method',
        service: 'my_cool_service',
        method_name: 'some_method',
        timeout: 1,
        open_after: 2,
        cool_off_after: 3
      )
    end

    let(:some_object) do
      double(:some_object)
    end

    context 'with success' do
      before do
        allow(some_object).to receive(:some_method).and_return('OK')
      end

      it 'returns the value' do
        is_expected.to eq('OK')
      end
    end

    context 'with fail' do
      before do
        allow(some_object).to receive(:some_method).and_raise(StandardError.new)
      end

      it 'returns the value' do
        expect{subject}.to raise_error(StandardError)
      end
    end

    context 'with the number of fails greater than the allowed by the circuit' do
      before do
        allow(some_object).to receive(:some_method).and_raise(StandardError.new)
      end

      it 'closes the circuit' do
        circuit.open_after.times { run_circuit rescue nil }

        expect { run_circuit }.to raise_error(Stoplight::Error::RedLight)
      end
    end
  end
end
