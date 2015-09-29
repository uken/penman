require 'spec_helper'

module Penman
  describe Configuration do
    describe '#configure' do
      it "should have a value of 'db' by default" do
        expect(Configuration.new.seed_path).to eq('db/migrate')
      end

      it 'should support seed_path configuration' do
        config = Configuration.new
        config.seed_path = 'some/path/where/seeds/should/go'
        expect(config.seed_path).to eq('some/path/where/seeds/should/go')
      end

      it 'should support default_candidate_key configuration' do
        config = Configuration.new
        config.default_candidate_key = :name
        expect(config.default_candidate_key).to eq(:name)
      end
    end
  end
end
