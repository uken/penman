require 'spec_helper'

module RecordTags
  describe RecordTags do
    describe '.seed_path' do
      before do
        RecordTags.configure do |config|
          config.seed_path = 'some/path/where/seeds/should/go'
        end
      end

      it 'should return the configured seed_path' do
        expect(RecordTags.seed_path).to eq('some/path/where/seeds/should/go')
      end
    end

    describe ".reset" do
      before :each do
        RecordTags.configure do |config|
          config.seed_path = 'some/path/where/seeds/should/go'
        end
      end

      it "resets the configuration" do
        RecordTags.reset
        config = RecordTags.configuration
        expect(config.seed_path).to eq('db')
      end
    end
  end
end
