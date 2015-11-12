require 'spec_helper'

describe Penman::SeedFileGenerator do
  describe '.write_seed' do
    it "should do nothing if the table doesn't exist" do
      ActiveRecord::Base.connection.stub(:table_exists?) { false }
      Penman::RecordTag.tag(Item.first, 'updated')
      expect {
        Penman.generate_seeds
      }.to_not change {
        ActiveRecord::Base.connection.execute('select * from schema_migrations').count
      }
    end

    it "should create the SchemaMigrations model if it doesn't already exist"
    it "should do nothing if the schema migrations table does not incude a `versions` attribute"
    it 'should add the new seed version to the seed_migrations table if it does exist'
  end
end
