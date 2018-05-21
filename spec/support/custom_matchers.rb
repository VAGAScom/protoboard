require 'rspec/expectations'

RSpec::Matchers.define :be_a_circuit_with do |options|
  match do |circuit|
    expect(circuit.name).to eq(options[:name])
    expect(circuit.service).to eq(options[:service])
    expect(circuit.method_name).to eq(options[:method_name])
    expect(circuit.timeout).to eq(options[:timeout])
    expect(circuit.open_after).to eq(options[:open_after])
    expect(circuit.cool_off_after).to eq(options[:cool_off_after])
  end
end
