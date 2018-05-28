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

    context 'with before callbacks' do
      let(:some_action) { spy(:some_action) }
      let(:some_object) { double(:some_object, some_method: 'OK') }
      let(:circuit) {
        Protoboard::Circuit.new(
          name: 'my_cool_circuit_with_callbacks',
          service: 'my_cool_service',
          method_name: 'some_method',
          timeout: 1,
          open_after: 2,
          cool_off_after: 3,
          on_before: [->(circuit_execution) { some_action.call(circuit_execution.state) }]
        )
      }
      it 'calls the callbacks before the circuit execution' do
        run_circuit

        expect(some_action).to have_received(:call).with(:pending)
      end
    end

    context 'with after callbacks' do
      let(:some_action) { spy(:some_action) }
      let(:some_object) { double(:some_object, some_method: 'OK') }
      let(:circuit) {
        Protoboard::Circuit.new(
          name: 'my_cool_circuit_with_callbacks',
          service: 'my_cool_service',
          method_name: 'some_method',
          timeout: 1,
          open_after: 2,
          cool_off_after: 3,
          on_after: [->(circuit_execution) { some_action.call(circuit_execution.state) }]
        )
      }

      context 'when the action complete' do
        before { allow(some_object).to receive(:some_method).and_return('OK') }

        it 'calls the callbacks after the circuit execution' do
          run_circuit

          expect(some_action).to have_received(:call).with(:success)
        end
      end

      context 'when the action fails' do
        before { allow(some_object).to receive(:some_method).and_raise(StandardError.new) }

        it 'calls the callbacks after the circuit execution' do
          run_circuit rescue StandardError

          expect(some_action).to have_received(:call).with(:fail)
        end
      end
    end

    context 'with both callbacks' do
      let(:some_action) { spy(:some_action) }
      let(:some_object) { double(:some_object, some_method: 'OK') }
      let(:circuit) {
        Protoboard::Circuit.new(
          name: 'my_cool_circuit_with_callbacks',
          service: 'my_cool_service',
          method_name: 'some_method',
          timeout: 1,
          open_after: 2,
          cool_off_after: 3,
          on_after: [->(circuit_execution) { some_action.call(circuit_execution.state, 'after') }],
          on_before: [->(circuit_execution) { some_action.call(circuit_execution.state, 'before') }]
        )
      }

      it 'calls the callbacks before the circuit execution' do
        run_circuit

        expect(some_action).to have_received(:call).with(:pending, 'before').once
      end

      context 'when the action complete' do
        before { allow(some_object).to receive(:some_method).and_return('OK') }

        it 'calls the callbacks after the circuit execution' do
          run_circuit

          expect(some_action).to have_received(:call).with(:success, 'after').once
        end
      end

      context 'when the action fails' do
        before { allow(some_object).to receive(:some_method).and_raise(StandardError.new) }

        it 'calls the callbacks after the circuit execution' do
          run_circuit rescue StandardError

          expect(some_action).to have_received(:call).with(:fail, 'after').once
        end
      end
    end
  end
end
