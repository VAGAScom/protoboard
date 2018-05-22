RSpec.describe Protoboard do
  it "has a version number" do
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
  end
end
