require 'spec_helper'

module RecordTags
  describe Configuration do
    describe '#configure' do
      it "should have a value of 'db' by default" do
        expect(Configuration.new.seed_path).to eq('db')
      end

      it 'should support seed_path configuration' do
        config = Configuration.new
        config.seed_path = 'some/path/where/seeds/should/go'
        expect(config.seed_path).to eq('some/path/where/seeds/should/go')
      end
    end
  end
end
