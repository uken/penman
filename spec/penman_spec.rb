require 'spec_helper'

module Penman
  describe Penman do
    describe '.seed_path' do
      before do
        Penman.configure do |config|
          config.seed_path = 'some/path/where/seeds/should/go'
          config.default_candidate_key = :some_other_attribute
          config.seed_template_file = 'some_file'
          config.file_name_formatter = lambda do |model_name, seed_type|
            "some_crazy_#{model_name}_#{seed_type}_seed"
          end
        end
      end

      it 'should return the configured seed_path' do
        expect(Penman.config.seed_path).to eq('some/path/where/seeds/should/go')
      end

      it 'should support default_candidate_key configuration' do
        expect(Penman.config.default_candidate_key).to eq(:some_other_attribute)
      end

      it 'should support seed_template_file configuration' do
        expect(Penman.config.seed_template_file).to eq('some_file')
      end

      it 'should support a custom file name formatter lambda' do
        expect(Penman.config.file_name_formatter.call('Model', 'destroys')).to eq('some_crazy_Model_destroys_seed')
      end
    end

    describe '.reset' do
      before :each do
        Penman.configure do |config|
          config.seed_path = 'some/path/where/seeds/should/go'
          config.default_candidate_key = :name
          config.seed_template_file = 'some_file.erb'
          config.file_name_formatter = lambda do |model_name, seed_type|
            "some_crazy_#{model_name}_#{seed_type}_seed"
          end
        end

        Penman.reset
        @config = Penman.config
      end

      it 'resets the seed_path configuration' do
        expect(@config.seed_path).to eq('db/migrate')
      end

      it 'resets the default_candidate_key configuration' do
        expect(@config.default_candidate_key).to eq(:reference)
      end

      it 'resets the seed_template_file configuration' do
        expect(@config.seed_template_file).to match(/default.rb.erb/)
      end

      it 'resets the file_name_formatter back to the usual way' do
        expect(@config.file_name_formatter.call('SomeModel', 'updates')).to eq('some_models_updates')
      end
    end

    describe '.enabled' do
      it 'should return true if Penman is enabled' do
        Penman.enable
        expect(Penman.enabled?).to be true
      end

      it 'shoud return false if Penman is disabled' do
        Penman.disable
        expect(Penman.enabled?).to be false
      end
    end
  end
end
