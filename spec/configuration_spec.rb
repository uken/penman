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

        it "should have a default value matching 'default.rb.erb' for the seed template file" do
          expect(@config.seed_template_file).to match(/default.rb.erb/)
        end

        it 'should format the filename in the usual way' do
          expect(@config.file_name_formatter.call('SomeModel', 'updates')).to eq('some_models_updates')
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

      it 'should support seed_template_file configuration' do
        @config.seed_template_file = 'some_file'
        expect(@config.seed_template_file).to eq('some_file')
      end

      it 'should support a custom file name formatter lambda' do
        @config.file_name_formatter = lambda do |model_name, seed_type|
          "some_crazy_#{model_name}_#{seed_type}_seed"
        end

        expect(@config.file_name_formatter.call('Model', 'destroys')).to eq('some_crazy_Model_destroys_seed')
      end
    end
  end
end
