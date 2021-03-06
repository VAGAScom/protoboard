
# frozen_string_literal: true

RSpec.describe Protoboard::CircuitBreaker do
  before do
    clean_circuits
    disable_constant_warnings
  end

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
          name: 'my_cool_service/Foo1#some_method',
          service: 'my_cool_service',
          method_name: :some_method,
          open_after: 2,
          cool_off_after: 3
        )
      end

      context 'with a singleton method' do
        let(:define_circuit_class) do
          class Foo1
            include Protoboard::CircuitBreaker

            register_circuits [:some_singleton_method],
                              singleton_methods: [:some_singleton_method],
                              options: {
                                service: 'my_cool_service',
                                open_after: 2,
                                cool_off_after: 3
                              }

            def self.some_singleton_method
              raise StandardError
            end
          end
        end

        it 'registers a circuit' do
          define_circuit_class

          expect(Protoboard::CircuitBreaker.registered_circuits.size).to eq(1)

          circuit = Protoboard::CircuitBreaker.registered_circuits.first

          expect(circuit).to be_a_circuit_with(
            name: 'my_cool_service/Foo1#some_singleton_method',
            service: 'my_cool_service',
            method_name: :some_singleton_method,
            open_after: 2,
            cool_off_after: 3
          )

          expect(circuit.singleton_method?).to eq(true)
        end
      end

      context 'with a namespace' do
        let(:namespace) { 'Foo' }

        before { allow(Protoboard.config).to receive(:namespace).and_return(namespace) }

        it 'registers a circuit' do
          define_circuit_class

          circuit = Protoboard::CircuitBreaker.registered_circuits.first
          expect(circuit).to be_a_circuit_with(
            name: "#{namespace}/my_cool_service/Foo1#some_method",
            service: 'my_cool_service',
            method_name: :some_method,
            open_after: 2,
            cool_off_after: 3
          )
        end
      end

      context 'with a custom circuit name' do
        context 'with no singleton method' do
          let(:define_circuit_class) do
            class Foo1
              include Protoboard::CircuitBreaker

              register_circuits({ some_method: 'my_custom_circuit_name' },
                                options: {
                                  service: 'my_cool_service',
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
              name: 'my_custom_circuit_name',
              service: 'my_cool_service',
              method_name: :some_method,
              open_after: 2,
              cool_off_after: 3
            )
          end
        end

        context 'with singleton methods' do
          let(:define_circuit_class) do
            class Foo1
              include Protoboard::CircuitBreaker

              register_circuits({ some_singleton_method: 'my_custom_circuit_name' },
                                singleton_methods: [:some_singleton_method],
                                options: {
                                  service: 'my_cool_service',
                                  open_after: 2,
                                  cool_off_after: 3
                                })
              def self.some_singleton_method
                raise StandardError
              end
            end
          end

          it 'registers a circuit' do
            define_circuit_class

            circuit = Protoboard::CircuitBreaker.registered_circuits.first
            expect(circuit).to be_a_circuit_with(
              name: 'my_custom_circuit_name',
              service: 'my_cool_service',
              method_name: :some_singleton_method,
              open_after: 2,
              cool_off_after: 3
            )

            expect(circuit.singleton_method?).to eq(true)
          end
        end
      end

      context 'with valid callbacks' do
        let(:define_circuit_class) do
          class Foo1
            include Protoboard::CircuitBreaker

            register_circuits({ some_method: 'my_custom_circuit_name' },
                              on_before: [->(_) {}, ->(_) {}],
                              on_after: [->(_) {}, ->(_) {}],
                              options: {
                                service: 'my_cool_service',
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
            name: 'my_custom_circuit_name',
            service: 'my_cool_service',
            method_name: :some_method,
            open_after: 2,
            cool_off_after: 3,
            on_before: [->(_) {}, ->(_) {}],
            on_after: [->(_) {}, ->(_) {}]
          )
        end
      end

      context 'with invalid callbacks' do
        let(:define_circuit_class) do
          class Foo1
            include Protoboard::CircuitBreaker

            register_circuits({ some_method: 'my_custom_circuit_name' },
                              on_before: [1, -> {}],
                              on_after: [-> {}, 'not_a_callback'],
                              options: {
                                service: 'my_cool_service',
                                open_after: 2,
                                cool_off_after: 3
                              })
            def some_method
              raise StandardError
            end
          end
        end

        it 'raises a error' do
          expect { define_circuit_class }.to raise_error(Protoboard::Errors::InvalidCallback)
        end
      end
    end

    context 'with two circuits' do
      it 'resgisters two circuits' do
        class Foo2
          include Protoboard::CircuitBreaker

          register_circuits %i[some_method1 some_method2],
                            options: {
                              service: 'my_cool_service',
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
          name: 'my_cool_service/Foo2#some_method1',
          service: 'my_cool_service',
          method_name: :some_method1,
          open_after: 2,
          cool_off_after: 3
        )

        circuit = Protoboard::CircuitBreaker.registered_circuits.last
        expect(circuit).to be_a_circuit_with(
          name: 'my_cool_service/Foo2#some_method2',
          service: 'my_cool_service',
          method_name: :some_method2,
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
                            open_after: 2,
                            cool_off_after: 3
                          }
        def some_method
          raise StandardError
        end
      end

      expect(FooService.ancestors.first).to eq(Protoboard::SomeMethodFooServiceCircuitProxy::InstanceMethods)
    end

    context 'with singleton methods' do
      it 'prepends a module to the singleton class' do
        class FooService
          include Protoboard::CircuitBreaker

          register_circuits [:some_method, :some_singleton_method],
                            singleton_methods: [:some_singleton_method],
                            options: {
                              service: 'my_cool_service',
                              open_after: 2,
                              cool_off_after: 3
                            }

          def self.some_singleton_method
            "It's ok"
          end
        end

        expect(FooService.singleton_class.ancestors.first)
          .to eq(Protoboard::SomeMethodSomeSingletonMethodFooServiceCircuitProxy::ClassMethods)
      end
    end

    context 'with fallback' do
      context 'when no error occurs' do
        it 'doesnt call the fallback' do
          class FooFallback1
            include Protoboard::CircuitBreaker

            register_circuits [:some_method],
                              fallback: ->(_e) { 'Not Nice' },
                              options: {
                                service: 'my_cool_fallback',
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
                              fallback: ->(_e) { 'Not Nice' },
                              options: {
                                service: 'my_cool_fallback2',
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

  describe '.services_healthcheck' do
    subject { described_class.services_healthcheck(options) }
    let(:options) { {} }

    context 'with no circuit registered' do
      it 'returns a hash with all services and circuit states' do
        is_expected.to eq({ 'services' => {} })
      end
    end

    context 'with one circuit registered' do
      it 'returns a hash with all services and circuit states' do
        class Foo3
          include Protoboard::CircuitBreaker

          register_circuits [:some_method],
                            options: {
                              service: 'my_service_name',
                              open_after: 2,
                              cool_off_after: 3
                            }
          def some_method
            'OK'
          end
        end

        is_expected.to eq(
          'services' => {
            'my_service_name' => {
              'circuits' => {
                'my_service_name/Foo3#some_method' => 'OK'
              }
            }
          }
        )
      end
    end

    context 'when registering circuits with custom names' do
      it 'returns a hash with all services and circuit states' do
        class Foo4
          include Protoboard::CircuitBreaker

          register_circuits({ some_method: 'my_custom_name', other_method: 'my_other_custom_name' },
                            options: {
                              service: 'my_service_name',
                              open_after: 2,
                              cool_off_after: 3
                            })
          def some_method
            'OK'
          end
        end

        is_expected.to eq(
          'services' => {
            'my_service_name' => {
              'circuits' => {
                'my_custom_name' => 'OK',
                'my_other_custom_name' => 'OK'
              }
            }
          }
        )
      end

      context 'with a namespace' do
        before do
          Protoboard.configure do |config|
            config.namespace = 'Bazz'
          end
        end

        it 'returns a hash with all services and circuit states' do
          class Foo4
            include Protoboard::CircuitBreaker

            register_circuits({ some_method: 'my_custom_name', other_method: 'my_other_custom_name' },
                              options: {
                                service: 'my_service_name',
                                open_after: 2,
                                cool_off_after: 3
                              })
            def some_method
              'OK'
            end
          end

          is_expected.to eq(
                           'services' => {
                             'my_service_name' => {
                               'circuits' => {
                                 'Bazz/my_custom_name' => 'OK',
                                 'Bazz/my_other_custom_name' => 'OK'
                               }
                             }
                           }
                         )
        end

        context 'with option with_namespace to false' do
          let(:options) { { with_namespace: false} }

          it 'returns a hash with all services and circuit states' do
            class Foo5
              include Protoboard::CircuitBreaker

              register_circuits({ some_method: 'my_custom_name', other_method: 'my_other_custom_name' },
                                options: {
                                  service: 'my_service_name',
                                  open_after: 2,
                                  cool_off_after: 3
                                })
              def some_method
                'OK'
              end
            end

            is_expected.to eq(
                             'services' => {
                               'my_service_name' => {
                                 'circuits' => {
                                   'my_custom_name' => 'OK',
                                   'my_other_custom_name' => 'OK'
                                 }
                               }
                             }
                           )
          end
        end
      end
    end
  end
end
