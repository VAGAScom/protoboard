# frozen_string_literal: true

RSpec.describe Protoboard::CircuitProxyFactory do
  describe '.create_module' do
    let(:circuit1) do
      Protoboard::Circuit.new(
        name: 'my_cool_service#some_method',
        service: 'my_cool_service',
        method_name: 'some_method',
        timeout: 1,
        open_after: 2,
        cool_off_after: 3
      )
    end

    let(:circuit2) do
      Protoboard::Circuit.new(
        name: 'my_cool_service#some_method2',
        service: 'my_cool_service',
        method_name: 'some_method2',
        timeout: 1,
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

        expect(subject.instance_methods).to include(:some_method, :some_method2)
      end
    end

    context 'with a class name containing namespace' do
      let(:class_name) { 'Foo::Bar' }

      it 'returns a module proxying the methods' do
        is_expected.to eq(Protoboard::SomeMethodSomeMethod2FooBarCircuitProxy)

        expect(subject.instance_methods).to include(:some_method, :some_method2)
      end
    end

    it 'defines a proxy for the given methods' do
      expect(Protoboard::Adapters::StoplightAdapter).to receive(:run_circuit).once

      create_module

      class FooBar
        prepend Protoboard::SomeMethodSomeMethod2FooBarCircuitProxy
        def some_method; end
      end

      FooBar.new.some_method
    end
  end
end
