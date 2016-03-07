require 'spec_helper'

module Penman
  describe Configuration do
    describe '#configure' do
      before { @config = Configuration.new }

      context 'regarding default values' do
        it "should have a value of 'db/migrate' by default for seed_path" do
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

        it 'should have a default `validate_records_before_seed_generation` value of false' do
          expect(@config.validate_records_before_seed_generation).to be false
        end
      end

      it 'should support `seed_path` configuration' do
        @config.seed_path = 'some/path/where/seeds/should/go'
        expect(@config.seed_path).to eq('some/path/where/seeds/should/go')
      end

      it 'should support `default_candidate_key` configuration' do
        @config.default_candidate_key = :some_other_attribute
        expect(@config.default_candidate_key).to eq(:some_other_attribute)
      end

      it 'should support `seed_template_file` configuration' do
        @config.seed_template_file = 'some_file'
        expect(@config.seed_template_file).to eq('some_file')
      end

      it 'should support `validate_records_before_seed_generation` configuration' do
        @config.validate_records_before_seed_generation = true
        expect(@config.validate_records_before_seed_generation).to be true
      end

      it 'should support a custom file name formatter lambda' do
        @config.file_name_formatter = lambda do |model_name, seed_type|
          "some_crazy_#{model_name}_#{seed_type}_seed"
        end

        expect(@config.file_name_formatter.call('Model', 'destroys')).to eq('some_crazy_Model_destroys_seed')
      end
    end

    describe 'after_generate config default' do
      before { @version = rand(99999999).to_s }

      it "should do nothing if the table doesn't exist" do
        allow(ActiveRecord::Base.connection).to receive(:table_exists?).and_return(false)
        expect {
          Penman.config.after_generate.call(@version, 'updates')
        }.to_not change {
          ActiveRecord::Base.connection.execute('select * from schema_migrations').count
        }
      end

      it "should create the SchemaMigrations model if it doesn't already exist" do
        Object.send(:remove_const, :SchemaMigration) if Object.const_defined?('SchemaMigration')
        expect { SchemaMigration }.to raise_error(NameError)
        Penman.config.after_generate.call(@version, 'updates')
        expect { SchemaMigration }.not_to raise_error
      end

      it "should do nothing if the schema migrations table does not incude a `versions` attribute" do
        unless Object.const_defined?('SchemaMigration')
          Object.const_set('SchemaMigration', Class.new(ActiveRecord::Base))
        end

        allow(SchemaMigration).to receive(:column_names).and_return([])

        expect {
          Penman.config.after_generate.call(@version, 'updates')
        }.to_not change {
          ActiveRecord::Base.connection.execute('select * from schema_migrations').count
        }
      end

      it 'should add the new seed version to the seed_migrations table if it does exist' do
        expect {
          Penman.config.after_generate.call(@version, 'updates')
        }.to change {
          ActiveRecord::Base.connection.execute('select * from schema_migrations').count
        }.by(1)
      end
    end
  end
end
