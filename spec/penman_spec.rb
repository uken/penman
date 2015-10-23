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

    describe '.seed_method_name' do
      before do
        Penman.configure do |config|
          config.seed_method_name = :up
        end
      end

      it 'should return the configured seed_method_name' do
        expect(Penman.seed_method_name).to eq(:up)
      end
    end

    describe ".reset" do
      before :each do
        Penman.configure do |config|
          config.seed_path = 'some/path/where/seeds/should/go'
          config.default_candidate_key = :name
          config.seed_method_name = :some_crazy_name
          config.seed_template_file = 'some_file.erb'
        end

        Penman.reset
        @config = Penman.config
      end

      it "resets the seed_path configuration" do
        expect(@config.seed_path).to eq('db/migrate')
      end

      it "resets the default_candidate_key configuration" do
        expect(@config.default_candidate_key).to eq(:reference)
      end

      it "resets the seed_method_name configuration" do
        expect(@config.seed_method_name).to eq(:change)
      end

      it "resets the seed_template_file configuration" do
        expect(@config.seed_template_file).to match(/default.rb.erb/)
      end
    end
  end
end
