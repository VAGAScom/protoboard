# frozen_string_literal: true

RSpec.describe Protoboard do
  it 'has a version number' do
    expect(Protoboard::VERSION).not_to be nil
  end

  describe '.configure' do
    it 'configure the adapter and its options' do
      Protoboard.configure do |config|
        config.adapter = Protoboard::Adapters::StoplightAdapter

        config.adapter.configure do |adapter|
          adapter.data_store = :redis
          adapter.redis_host = 'localhost'
          adapter.redis_port = 1234
        end
      end

      expect(Protoboard.config.adapter).to eq(Protoboard::Adapters::StoplightAdapter)
      expect(Protoboard.config.adapter.data_store).to eq(:redis)
      expect(Protoboard.config.adapter.redis_host).to eq('localhost')
      expect(Protoboard.config.adapter.redis_port).to eq(1234)
    end

    context 'when passing a namespace' do
      it 'configure the adapter and its options containing the namespace' do
        Protoboard.configure do |config|
          config.namespace = 'Foo'
        end

        expect(Protoboard.config.namespace).to eq('Foo')
      end
    end

    context 'when passing a list of callbacks' do
      let(:callable_object) do
        Class.new do
          def call(_); end
        end.new
      end
      it 'configure the callbacks' do
        Protoboard.configure do |config|
          config.callbacks.tap do |callback|
            callback.before = [callable_object, ->(_) {}]
            callback.after = [callable_object, ->(_) {}]
          end
        end

        expect(Protoboard.config.callbacks.before.size).to eq(2)
        expect(Protoboard.config.callbacks.after.size).to eq(2)
        expect(Protoboard.config.callbacks.before).to all(respond_to(:call))
        expect(Protoboard.config.callbacks.after).to all(respond_to(:call))
      end
    end

    context 'with invalid before callback' do
      it 'raises a error' do
        expect do
          Protoboard.configure do |config|
            config.callbacks.tap do |callback|
              callback.before = [-> {}]
              callback.after = [->(_) {}]
            end
          end
        end.to raise_error(Protoboard::Errors::InvalidCallback)
      end
    end

    context 'with invalid after callback' do
      it 'raises a error' do
        expect do
          Protoboard.configure do |config|
            config.callbacks.tap do |callback|
              callback.before = [->(_) {}]
              callback.after = [-> {}]
            end
          end
        end.to raise_error(Protoboard::Errors::InvalidCallback)
      end
    end
  end
end
