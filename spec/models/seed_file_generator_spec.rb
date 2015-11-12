require 'spec_helper'

describe Penman::SeedFileGenerator do
  describe '.write_seed' do
    it 'should callthe `after_generate` callback' do
      seed_file_generator = Penman::SeedFileGenerator.new(
        'some_file_name',
        '123456',
        Penman::SeedCode.new
      )
      allow(IO).to receive(:write)
      allow(Penman.config.after_generate).to receive(:call)
      seed_file_generator.write_seed
      expect(Penman.config.after_generate).to have_received(:call)
    end
  end
end
