require 'spec_helper'

module Penman
  describe Penman do
    describe '.seed_path' do
      before do
        Penman.configure do |config|
          config.seed_path = 'some/path/where/seeds/should/go'
        end
      end

      it 'should return the configured seed_path' do
        expect(Penman.seed_path).to eq('some/path/where/seeds/should/go')
      end
    end

    describe ".reset" do
      before :each do
        Penman.configure do |config|
          config.seed_path = 'some/path/where/seeds/should/go'
          config.default_candidate_key = :name
        end
      end

      it "resets the seed_path configuration" do
        Penman.reset
        config = Penman.configuration
        expect(config.seed_path).to eq('db/migrate')
      end

      it "resets the default_candidate_key configuration" do
        Penman.reset
        config = Penman.configuration
        expect(config.default_candidate_key).to eq(:reference)
      end
    end
  end
end
