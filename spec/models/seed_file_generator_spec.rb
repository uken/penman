require 'spec_helper'

describe Penman::SeedFileGenerator do
  describe '.write_seed' do
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

    it 'should be called in `generate_seeds`' do
      Penman.enable
      Penman::RecordTag.tag(Item.first, 'updated')
      Penman.disable
      allow(Penman.config.after_generate).to receive(:call)
      Penman.generate_seeds
      expect(Penman.config.after_generate).to have_received(:call)
    end
  end
end
