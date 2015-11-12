require 'spec_helper'

describe Penman::SeedFileGenerator do
  describe '.write_seed' do
    it 'should callthe `after_generate` callback' do
      Penman.enable
      Penman::RecordTag.tag(Item.first, 'updated')
      Penman.disable
      allow(Penman.config.after_generate).to receive(:call)
      Penman.generate_seeds
      expect(Penman.config.after_generate).to have_received(:call)
    end
  end
end
