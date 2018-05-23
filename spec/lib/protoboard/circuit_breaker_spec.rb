
RSpec.describe Protoboard::CircuitBreaker do

  before { clean_circuits }

  describe '.register_circuits' do
    context 'when included' do
      it 'adds singleton method register_circuits' do
        my_class = Class.new
        my_class.include described_class
        expect(my_class).to respond_to(:register_circuits)
      end
    end

    context 'with one circuit' do
      let(:define_circuit_class) do
        class Foo1
          include Protoboard::CircuitBreaker

          register_circuits [:some_method],
                            options: {
                              service: 'my_cool_service',
                              timeout: 1,
                              open_after: 2,
                              cool_off_after: 3
                            }
          def some_method
            raise StandardError
          end
        end
      end

      it 'registers a circuit' do
        define_circuit_class

        expect(Protoboard::CircuitBreaker.registered_circuits.size).to eq(1)

        circuit = Protoboard::CircuitBreaker.registered_circuits.first
        expect(circuit).to be_a_circuit_with(
                             name: 'my_cool_service#some_method',
                             service: 'my_cool_service',
                             method_name: :some_method,
                             timeout: 1,
                             open_after: 2,
                             cool_off_after: 3
                           )

      end

      context 'with a namespace' do
        let(:namespace) { 'Foo' }

        before { allow(Protoboard.config).to receive(:namespace).and_return(namespace) }

        it 'registers a circuit' do
          define_circuit_class

          circuit = Protoboard::CircuitBreaker.registered_circuits.first
          expect(circuit).to be_a_circuit_with(
                               name: "#{namespace}/my_cool_service#some_method",
                               service: 'my_cool_service',
                               method_name: :some_method,
                               timeout: 1,
                               open_after: 2,
                               cool_off_after: 3
                             )
        end
      end

      context 'with a custom circuit name' do
        let(:define_circuit_class) do
          class Foo1
            include Protoboard::CircuitBreaker

            register_circuits({ some_method: 'my_custom_circuit_name' },
                                options: {
                                service: 'my_cool_service',
                                timeout: 1,
                                open_after: 2,
                                cool_off_after: 3
                              })
            def some_method
              raise StandardError
            end
          end
        end

        it 'registers a circuit' do
          define_circuit_class

          circuit = Protoboard::CircuitBreaker.registered_circuits.first
          expect(circuit).to be_a_circuit_with(
                               name: "my_custom_circuit_name",
                               service: 'my_cool_service',
                               method_name: :some_method,
                               timeout: 1,
                               open_after: 2,
                               cool_off_after: 3
                             )
        end
      end

      context 'with callbacks' do
        let(:define_circuit_class) do
          class Foo1
            include Protoboard::CircuitBreaker

            register_circuits({ some_method: 'my_custom_circuit_name' },
                                options: {
                                service: 'my_cool_service',
                                timeout: 1,
                                open_after: 2,
                                cool_off_after: 3,
                                on_before: [->{}, ->{}],
                                on_after: [->{}, ->{}]
                              })
            def some_method
              raise StandardError
            end
          end
        end

        xit 'registers a circuit' do
          define_circuit_class

          circuit = Protoboard::CircuitBreaker.registered_circuits.first
          expect(circuit).to be_a_circuit_with(
                               name: "my_cool_service#some_method",
                               service: 'my_cool_service',
                               method_name: :some_method,
                               timeout: 1,
                               open_after: 2,
                               cool_off_after: 3,
                               on_before: [->{}, ->{}],
                               on_after: [->{}, ->{}]
                             )
        end
      end
    end

    context 'with two circuits' do
      it 'resgisters two circuits' do
        class Foo2
          include Protoboard::CircuitBreaker

          register_circuits [:some_method1, :some_method2],
                            options: {
                              service: 'my_cool_service',
                              timeout: 1,
                              open_after: 2,
                              cool_off_after: 3
                            }
          def some_method1
            raise StandardError
          end

          def some_method2
            raise StandardError
          end
        end

        expect(Protoboard::CircuitBreaker.registered_circuits.size).to eq(2)

        circuit = Protoboard::CircuitBreaker.registered_circuits.first
        expect(circuit).to be_a_circuit_with(
                             name: 'my_cool_service#some_method1',
                             service: 'my_cool_service',
                             method_name: :some_method1,
                             timeout: 1,
                             open_after: 2,
                             cool_off_after: 3
                           )

        circuit = Protoboard::CircuitBreaker.registered_circuits.last
        expect(circuit).to be_a_circuit_with(
                             name: 'my_cool_service#some_method2',
                             service: 'my_cool_service',
                             method_name: :some_method2,
                             timeout: 1,
                             open_after: 2,
                             cool_off_after: 3
                           )
      end
    end

    it 'prepends a module to proxy requests' do
      class FooService
        include Protoboard::CircuitBreaker

        register_circuits [:some_method],
                          options: {
                            service: 'my_cool_service',
                            timeout: 1,
                            open_after: 2,
                            cool_off_after: 3
                          }
        def some_method
          raise StandardError
        end
      end

      expect(FooService.ancestors.first).to eq(Protoboard::FooServiceCircuitProxy)
    end

    context 'with fallback' do
      context 'when no error occurs' do
        it 'doesnt call the fallback' do
          class FooFallback1
            include Protoboard::CircuitBreaker

            register_circuits [:some_method],
                              fallback: -> (e) { 'Not Nice' },
                              options: {
                                service: 'my_cool_fallback',
                                timeout: 1,
                                open_after: 2,
                                cool_off_after: 3
                              }
            def some_method
              'All Nice'
            end
          end

          expect(FooFallback1.new.some_method).to eq('All Nice')
        end
      end
      context 'when a error occurs' do
        it 'calls the fallback' do
          class FooFallback2
            include Protoboard::CircuitBreaker

            register_circuits [:some_method],
                              fallback: -> (e) {  'Not Nice' },
            options: {
              service: 'my_cool_fallback2',
              timeout: 1,
              open_after: 2,
              cool_off_after: 3
            }
            def some_method
              raise StandardError
            end
          end

          expect(FooFallback2.new.some_method).to eq('Not Nice')
        end
      end
    end
  end
end
