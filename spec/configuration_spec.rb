require 'spec_helper'

module Penman
  describe Configuration do
    describe '#configure' do
      before { @config = Configuration.new }

      context 'regarding default values' do
        it "should have a value of 'db' by default for seed_path" do
          expect(@config.seed_path).to eq('db/migrate')
        end

        it 'should support default_candidate_key configuration' do
          @config.default_candidate_key = :name
          expect(@config.default_candidate_key).to eq(:name)
        end

        it "should have a value of 'change' by default for seed_method_name" do
          expect(@config.seed_method_name).to eq(:change)
        end

        it 'should have a default nil value for the seed template file' do
          expect(@config.seed_template_file).to be_nil
        end
      end

      it 'should support seed_path configuration' do
        @config.seed_path = 'some/path/where/seeds/should/go'
        expect(@config.seed_path).to eq('some/path/where/seeds/should/go')
      end

      it 'should support default_candidate_key configuration' do
        @config.default_candidate_key = :some_other_attribute
        expect(@config.default_candidate_key).to eq(:some_other_attribute)
      end

      it 'should support seed_method_name configuration' do
        @config.seed_method_name = :up
        expect(@config.seed_method_name).to eq(:up)
      end

      it 'should support seed_template_file configuration' do
        @config.seed_method_name = :up
        expect(@config.seed_method_name).to eq(:up)
      end
    end
  end
end
