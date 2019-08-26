# frozen_string_literal: true

RSpec.describe Protoboard::CircuitProxyFactory do
  before { disable_constant_warnings }

  describe '.create_module' do
    let(:circuit1) do
      Protoboard::Circuit.new(
        name: 'my_cool_service#some_method',
        service: 'my_cool_service',
        method_name: 'some_method',
        open_after: 2,
        cool_off_after: 3
      )
    end

    let(:circuit2) do
      Protoboard::Circuit.new(
        name: 'my_cool_service#some_method2',
        service: 'my_cool_service',
        method_name: 'some_method2',
        open_after: 2,
        cool_off_after: 3
      )
    end

    let(:circuits) do
      [circuit1, circuit2]
    end

    let(:class_name) { 'FooBar' }

    subject(:create_module) { described_class.create_module(circuits, class_name) }

    context 'with a name containing no namespace' do
      it 'returns a module proxying the methods' do
        is_expected.to eq(Protoboard::SomeMethodSomeMethod2FooBarCircuitProxy)

        expect(subject.const_get('InstanceMethods').instance_methods).to include(:some_method, :some_method2)
      end
    end

    context 'with a method name containing a bang caracter' do
      let(:circuit1) do
        Protoboard::Circuit.new(
          name: 'my_cool_service#some_method!',
          service: 'my_cool_service',
          method_name: 'some_method!',
          open_after: 2,
          cool_off_after: 3
        )
      end
      it 'returns a module proxying the methods' do
        is_expected.to eq(Protoboard::SomeMethodORD33SomeMethod2FooBarCircuitProxy)

        expect(subject.const_get('InstanceMethods').instance_methods).to include(:some_method!, :some_method2)
      end
    end

    context 'with a method name containing a equal caracter' do
      let(:circuit1) do
        Protoboard::Circuit.new(
          name: 'my_cool_service#some_method=',
          service: 'my_cool_service',
          method_name: 'some_method=',
          open_after: 2,
          cool_off_after: 3
        )
      end
      it 'returns a module proxying the methods' do
        is_expected.to eq(Protoboard::SomeMethodORD61SomeMethod2FooBarCircuitProxy)

        expect(subject.const_get('InstanceMethods').instance_methods).to include(:some_method=, :some_method2)
      end
    end

    context 'with a method name like a double equal' do
      let(:circuit1) do
        Protoboard::Circuit.new(
          name: 'my_cool_service#==',
          service: 'my_cool_service',
          method_name: '==',
          open_after: 2,
          cool_off_after: 3
        )
      end
      it 'returns a module proxying the methods' do
        is_expected.to eq(Protoboard::ORD61ORD61SomeMethod2FooBarCircuitProxy)

        expect(subject.const_get('InstanceMethods').instance_methods).to include(:==, :some_method2)
      end
    end

    context 'with a method name like a spaceship operator' do
      let(:circuit1) do
        Protoboard::Circuit.new(
          name: 'my_cool_service#<=>',
          service: 'my_cool_service',
          method_name: '<=>',
          open_after: 2,
          cool_off_after: 3
        )
      end
      it 'returns a module proxying the methods' do
        is_expected.to eq(Protoboard::ORD60ORD61ORD62SomeMethod2FooBarCircuitProxy)

        expect(subject.const_get('InstanceMethods').instance_methods).to include(:<=>, :some_method2)
      end
    end

    context 'with a class name containing namespace' do
      let(:class_name) { 'Foo::Bar' }

      it 'returns a module proxying the methods' do
        is_expected.to eq(Protoboard::SomeMethodSomeMethod2FooBarCircuitProxy)

        expect(subject::InstanceMethods.instance_methods).to include(:some_method, :some_method2)
      end
    end

    it 'defines a proxy for the given methods' do
      expect(Protoboard::Adapters::StoplightAdapter).to receive(:run_circuit).once

      create_module

      class FooBar
        prepend Protoboard::SomeMethodSomeMethod2FooBarCircuitProxy::InstanceMethods
        def some_method; end
      end

      FooBar.new.some_method
    end

    context 'when singleton_methods are passed' do
      let(:circuit1) do
        Protoboard::Circuit.new(
          name: 'my_cool_service#some_singleton_method',
          service: 'my_cool_service',
          method_name: 'some_singleton_method',
          open_after: 2,
          cool_off_after: 3,
          singleton_method: true
        )
      end

      it 'defines a proxy for the given methods' do
        expect(Protoboard::Adapters::StoplightAdapter).to receive(:run_circuit).once

        create_module

        class FooBar
          prepend Protoboard::SomeSingletonMethodSomeMethod2FooBarCircuitProxy::InstanceMethods

          class << self
            prepend Protoboard::SomeSingletonMethodSomeMethod2FooBarCircuitProxy::ClassMethods
            def some_singleton_method; end
          end
        end

        FooBar.some_singleton_method
      end

      it 'runs the code from the singleton_method' do
        create_module

        class FooBar
          prepend Protoboard::SomeSingletonMethodSomeMethod2FooBarCircuitProxy::InstanceMethods

          class << self
            prepend Protoboard::SomeSingletonMethodSomeMethod2FooBarCircuitProxy::ClassMethods
            def some_singleton_method
              'OK'
            end
          end
        end

        expect(FooBar.some_singleton_method).to eq('OK')
      end
    end
  end
end
