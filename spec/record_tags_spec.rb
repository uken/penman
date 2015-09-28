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
          config.default_candidate_key = :name
        end
      end

      it "resets the seed_path configuration" do
        RecordTags.reset
        config = RecordTags.configuration
        expect(config.seed_path).to eq('db')
      end

      it "resets the default_candidate_key configuration" do
        RecordTags.reset
        config = RecordTags.configuration
        expect(config.default_candidate_key).to eq(:reference)
      end
    end
  end
end
