require 'spec_helper'

def validate(record, default_attributes)
  expect(record).not_to be_nil
  candidate_key = record.class.try(:candidate_key) || :reference
  candidate_key = [candidate_key] unless candidate_key.is_a? Array

  default_attributes.reject { |k| candidate_key.include? k }.each do |k, v|
    if record.send(k).is_a? Time
      expect(record.send(k).to_i).to eq(v.to_i)
    else
      expect(record.send(k)).to eq(v)
    end
  end
end

def make_candidate_key_hash(model, candidate_key, index = 1)
  result = {}

  if model.name == 'MultiSetMember'
    result = { multi_set_id: MultiSet.last.id, setable_type: 'Item', setable_id: Item.take(index).last.id }
  else
    candidate_key.each do |column|
      result[column] =
        case model.column_types[column.to_s].type
        when :string
          "new_record_#{index}"
        when :integer
          index
        end
    end
  end

  result
end

def copy_to_new_record(record)
  attrs = record.as_json.delete_if { |k, _v| k == 'id' }
  record.destroy!
  record.class.create!(attrs)
end

def find_or_create_with_tag(model, hash)
  record = model.find_or_create_by!(hash)

  # just in case the record already existed
  Penman::RecordTag.tag(record, 'created') unless Penman::RecordTag.find_by(record: record).present?

  record
end

def simulate_record_having_been_present_previously(model, attributes)
  record = model.find_by(attributes)
  found_record = record.present?
  record = model.create!(attributes) unless found_record
  Penman::RecordTag.find_by(record: record).try(:destroy) # simulate record having been present previously if it was not
  record
end

def run_seed_spec_for_model(model, default_attributes)
  model_candidate_key = model.try(:candidate_key) || :reference
  model_candidate_key = [model_candidate_key] unless model_candidate_key.is_a? Array
  seed_files = []

  after do
    seed_files.each do |f|
      File.delete(f) if File.exist?(f)
    end

    seed_files = []
  end

  it 'should handle a single record tagged touched' do
    record = find_or_create_with_tag(
      model, default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))
    seed_files = Penman::RecordTag.generate_seed_for_model(model)
    record.destroy

    run_seed(seed_files)
    record = model.find_by(make_candidate_key_hash(model, model_candidate_key))
    validate(record, default_attributes)
  end

  it 'should handle multiple records tagged touched' do
    records = []

    1.upto(4) do |i|
      records << find_or_create_with_tag(
        model, default_attributes.merge(make_candidate_key_hash(model, model_candidate_key, i)))
    end

    seed_files = Penman::RecordTag.generate_seed_for_model(model)
    records.map(&:destroy)
    run_seed(seed_files)
    records = []

    1.upto(4) do |i|
      records << model.find_by(make_candidate_key_hash(model, model_candidate_key, i))
    end

    records.each do |record|
      validate(record, default_attributes)
    end
  end

  it 'should handle a single record tagged destroyed' do
    record = model.find_or_create_by!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))
    # simulate a record that was present before changes we made
    Penman::RecordTag.find_by(record: record, tag: 'created').try(:destroy)
    record.destroy
    seed_files = Penman::RecordTag.generate_seed_for_model(model)
    # simulate an environement that has the record
    model.create!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))

    run_seed(seed_files)

    record = model.find_by(make_candidate_key_hash(model, model_candidate_key))
    expect(record).to be_nil
  end

  it 'should handle multiple records tagged destroyed' do
    keys = []
    record_attributes = []

    1.upto(4) do |i|
      keys << make_candidate_key_hash(model, model_candidate_key, i)
      record_attributes << default_attributes.merge(keys.last)
    end

    records = record_attributes.map { |ra| model.find_or_create_by!(ra) }
    # simulate the records having been created in a previous seed
    Penman::RecordTag.where(record: records, tag: 'created').destroy_all
    records.map(&:destroy!) # generate 'destroyed' tags
    seed_files = Penman::RecordTag.generate_seed_for_model(model)
    record_attributes.each { |ra| model.find_or_create_by!(ra) } # simulate an environment that has these records

    run_seed(seed_files)
    records.clear
    records = keys.map { |k| model.find_by(k) }.compact

    expect(records.count).to eq(0)
  end

  it 'should handle creating, destroying, and creating again' do
    record = find_or_create_with_tag(
      model, default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))
    # tag destroyed, remove touched tag
    record.destroy
    # tag touched, remove destroyed tag
    record = model.create!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))

    seed_files = Penman::RecordTag.generate_seed_for_model(model)
    record.destroy

    run_seed(seed_files)

    record = model.find_by(make_candidate_key_hash(model, model_candidate_key))
    validate(record, default_attributes)
  end

  it 'should handle a mixture of touched and destroyed tags' do
    records = []

    1.upto(4) do |i|
      records << find_or_create_with_tag(
        model, default_attributes.merge(make_candidate_key_hash(model, model_candidate_key, i)))
    end

    # simulate records having been present before this seed
    Penman::RecordTag.where(record: [records[2], records[3]], tag: 'created').destroy_all

    records[2].destroy
    records[3].destroy

    seed_files = Penman::RecordTag.generate_seed_for_model(model)

    records[0].destroy
    records[1].destroy

    run_seed(seed_files)

    records = []

    1.upto(4) do |i|
      records << model.find_by(make_candidate_key_hash(model, model_candidate_key, i))
    end

    validate(records[0], default_attributes)
    validate(records[1], default_attributes)
    expect(records[2]).to be_nil
    expect(records[3]).to be_nil
  end

  it 'should not create duplicate records if executed more than once' do
    find_or_create_with_tag(model, default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))
    seed_files = Penman::RecordTag.generate_seed_for_model(model)

    run_seed(seed_files, 2) # run 2 times

    records = model.where(make_candidate_key_hash(model, model_candidate_key))
    expect(records.count).to eq(1)
    validate(records.first, default_attributes)
  end

  it 'should destroy a record if it was updated then destroyed' do
    record = simulate_record_having_been_present_previously(
      model, default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))
    record.update!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key, 2)))
    record.destroy!
    seed_files = Penman::RecordTag.generate_seed_for_model(model)

    model.create!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))
    run_seed(seed_files)

    record = model.find_by(make_candidate_key_hash(model, model_candidate_key))
    expect(record).to be_nil
  end

  it 'should update an existing record' do
    record = find_or_create_with_tag(
      model, default_attributes.merge(make_candidate_key_hash(model, model_candidate_key, 1)))
    record.update!(make_candidate_key_hash(model, model_candidate_key, 2))
    seed_files = Penman::RecordTag.generate_seed_for_model(model)
    record.destroy!
    model.create!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key, 1)))
    run_seed(seed_files)
    record = model.find_by(make_candidate_key_hash(model, model_candidate_key, 2))
    validate(record, default_attributes)
  end

  it 'should update the candidate key if changed' do
    record = model.find_or_create_by!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key, 1)))
    record.update!(make_candidate_key_hash(model, model_candidate_key, 2))
    seed_files = Penman::RecordTag.generate_seed_for_model(model)

    record.destroy
    model.create!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key, 1)))

    run_seed(seed_files)

    expect(model.find_by(make_candidate_key_hash(model, model_candidate_key, 2))).not_to be_nil
  end

  it 'should not leave a record around with an old candidate_key if updated' do
    # just in case the record existed before this test
    model.find_by(make_candidate_key_hash(model, model_candidate_key, 1)).try(:delete)
    model.find_by(make_candidate_key_hash(model, model_candidate_key, 2)).try(:delete)

    record = model.find_or_create_by!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key, 1)))
    record.update!(make_candidate_key_hash(model, model_candidate_key, 2))
    seed_files = Penman::RecordTag.generate_seed_for_model(model)

    record.destroy!
    model.create!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key, 1)))
    run_seed(seed_files)

    expect(model.find_by(make_candidate_key_hash(model, model_candidate_key, 1))).to be_nil
  end

  it 'should have no effect if we create and delete a model' do
    record = find_or_create_with_tag(
      model, default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))
    record.destroy
    seed_files = Penman::RecordTag.generate_seed_for_model(model)
    run_seed(seed_files)
    expect(model.find_by(make_candidate_key_hash(model, model_candidate_key))).to be_nil
  end

  it 'should remove any updated tags for a record if it is being tagged destroyed' do
    record = simulate_record_having_been_present_previously(
      model, default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))
    record.update!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key, 2)))
    record.destroy!
    expect(Penman::RecordTag.find_by(record: record, tag: 'updated')).to be_nil
  end

  it 'should result in no tags if a record is created then destroyed' do
    model.find_by(make_candidate_key_hash(model, model_candidate_key)).try(:delete)
    record = model.create!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))
    record.destroy!
    expect(Penman::RecordTag.find_by(record: record)).to be_nil
  end

  it 'should result in an updated tag if a record is destroyed then created' do
    record = simulate_record_having_been_present_previously(
      model, default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))
    record.destroy!
    record = model.create!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))
    expect(Penman::RecordTag.find_by(record: record, tag: 'updated')).to_not be_nil
  end

  belongs_to_associations = model.reflect_on_all_associations(:belongs_to)

  return unless belongs_to_associations.present?

  belongs_to_associations.each do |_association|
    # rubocop:disable Metrics/LineLength
    # associated_models = if association.polymorphic?
    #                       # only test associations that use record tags
    #                       associated_models_from_db = model.select(association.foreign_type).uniq.map(&association.foreign_type.to_sym)
    #                       associated_models_from_db.select! { |a| a.constantize.reflect_on_all_associations(:has_many).map(&:name).include?(:record_tags) }
    #                       associated_models_from_db.map(&:constantize)
    #                     else
    #                       [association.klass]
    #                     end
    # associated_models.each do |associated_model|
    #   associated_model_candidate_key = associated_model.try(:candidate_key) || :reference
    #   associated_model_candidate_key = [associated_model_candidate_key] unless associated_model_candidate_key.is_a? Array

    #   it "should seed the #{association.name} association properly when the #{association.name}'s id differs in the other environment." # do
    #     assoc_1 = associated_model.first

    #     unless assoc_1.nil? # this means that ths relation isn't used (we have an empty table). Probably this relation is defined in magra, and we just never use it on titans.
    #       assoc_2 = associated_model.last
    #       expect(assoc_1.id != assoc_2.id) # otherwise this test would be useless
    #       record = model.create!(default_attributes.merge(make_candidate_key_hash(model, model_candidate_key, 1, associated_model)).merge( { association.name => assoc_1 } ))

    #       seed_files = Penman::RecordTag.generate_seed_for_model(model)

    #       record.destroy
    #       assoc_1_key = {}

    #       associated_model_candidate_key.each do |key|
    #         assoc_1_key[key] = assoc_1.send(key)
    #       end

    #       assoc_1.update!(make_candidate_key_hash(associated_model, associated_model_candidate_key, 1, associated_model))
    #       assoc_2.update!(assoc_1_key)

    #       run_seed(seed_files)

    #       record = model.find_by(make_candidate_key_hash(model, model_candidate_key, 1, associated_model))
    #       expect(record.send(association.name)).to eq(assoc_2)
    #     end
    #   end
    # end

    reflection_in_candidate_key = belongs_to_associations.keep_if do |ass|
      model_candidate_key.include?(ass.foreign_key.to_sym)
    end

    reflection_in_candidate_key.each do |reflection|
      it 'should be able to identify the record even if a foreign key is a part of the candidate key, and '\
         "the foreign key isn't consistent between environments" do
        record = find_or_create_with_tag(
          model, default_attributes.merge(make_candidate_key_hash(model, model_candidate_key)))
        seed_files = Penman::RecordTag.generate_seed_for_model(model)

        # disable while we setup the environment so Penman::RecordTags doesn't compain about all the weird stuff we're doing
        Penman::RecordTag.disable
        associated_record = record.send(reflection.name)
        original_associated_record_id = associated_record.id
        associated_record = copy_to_new_record(associated_record)

        if model.find_by(make_candidate_key_hash(model, model_candidate_key).merge(
                           reflection.foreign_key.to_sym => associated_record.id)).nil?
          record.update!(reflection.foreign_key => associated_record.id)
        else # This is necessary if the associated model creates this record on create. There can be only one.
          record.destroy!
        end

        Penman::RecordTag.enable
        expect { run_seed(seed_files) }.to_not raise_error

        candidate_key_hash = make_candidate_key_hash(model, model_candidate_key)

        expect(
          model.where(candidate_key_hash.merge(reflection.foreign_key.to_sym => associated_record.id)).count
        ).to be(1)
        expect(
          model.where(candidate_key_hash.merge(reflection.foreign_key.to_sym => original_associated_record_id)).count
        ).to be(0)
      end
    end
  end
end

describe Penman::RecordTag do
  before(:all) { Penman.enable }
  after(:all) { Penman.disable }

  before do
    DatabaseCleaner.start
  end

  after do
    DatabaseCleaner.clean
  end

  describe '.tag' do
    let!(:record) {
      Weapon.create!(reference: 'some_weapon', damage_factor: 1, category: 'some_category', ranged: true)
    }

    it 'should remove any created tags for a record if it is being tagged destroyed' do
      record.destroy!
      expect(Penman::RecordTag.find_by(record_type: 'Weapon', record_id: record.id, tag: 'created')).to be_nil
    end

    it 'should replace destroyed tags for a record if it is being created again' do
      # This simulates someone destroying an element and raplacing it with another, which is a pattern we see often.
      # For example, when someone wants to replace an art asset with another one, and keep the same name.
      original_record_id = record.id
      record.destroy!
      second_record = Weapon.create!(reference: 'some_other_weapon', damage_factor: 1, category: 'some_category', ranged: true)
      expect(Penman::RecordTag.find_by(record_type: 'Weapon', record_id: original_record_id, tag: 'destroyed',
                               candidate_key: '{"reference":"some_other_weapon"}')).to be_nil
      expect(Penman::RecordTag.find_by(record_type: 'Weapon', record_id: second_record, tag: 'created',
                               candidate_key: '{"reference":"some_other_weapon"}')).not_to be_nil
    end

    it 'should destroy an updated tag if the record was created this session' do
      record.update!(reference: 'some_other_weapon')
      record.destroy!
      expect(Penman::RecordTag.find_by(record: record)).to be_nil
    end

    it 'should not destroy an updated tag if the record was not created this session' do
      Penman::RecordTag.find_by(record: record).destroy!
      record.update!(reference: 'some_other_weapon')
      expect(Penman::RecordTag.find_by(record: record)).to_not be_nil
    end
  end

  describe '.generate_seed_for_model' do
    # we will start by testing the weapon model being that it has all of the primitive
    # types that we are interested in at the moment
    it 'should seed a simple model with numbers' do
      weapon = Weapon.create(reference: 'new_weapon', category: 'name', category: 'some_category', damage_factor: 100)
      seed_files = Penman::RecordTag.generate_seed_for_model(Weapon)
      # simulate an environment in which this weapon does not exist
      # (ie. as if we had generated the seed on a design env and seeded on prod)
      weapon.destroy

      # require and run the seed
      run_seed(seed_files)

      weapon = Weapon.find_by(reference: 'new_weapon')
      expect(weapon).not_to be_nil
      expect(weapon.damage_factor).to eq(100)
    end

    it 'should seed a simple model with strings' do
      weapon = Weapon.create(reference: 'new_weapon', category: 'some_category')
      seed_files = Penman::RecordTag.generate_seed_for_model(Weapon)
      weapon.destroy

      run_seed(seed_files)

      weapon = Weapon.find_by(reference: 'new_weapon')
      expect(weapon).not_to be_nil
      expect(weapon.category).to eq('some_category')
    end

    it 'should seed a simple model with nil values' do
      weapon = Weapon.create(reference: 'new_weapon', category: 'some_category', damage_factor: nil)
      seed_files = Penman::RecordTag.generate_seed_for_model(Weapon)
      weapon.destroy

      run_seed(seed_files)

      weapon = Weapon.find_by(reference: 'new_weapon')
      expect(weapon).not_to be_nil
      expect(weapon.damage_factor).to be_nil
    end

    it 'should seed a simple model with times' do
      weapon = Weapon.create(reference: 'new_weapon', category: 'some_category')
      updated_at = weapon.updated_at
      seed_files = Penman::RecordTag.generate_seed_for_model(Weapon)
      weapon.destroy

      run_seed(seed_files)

      weapon = Weapon.find_by(reference: 'new_weapon')
      expect(weapon).not_to be_nil
      expect(weapon.updated_at.to_i).to eq(updated_at.to_i)
    end

    it 'should seed a simple model with booleans' do
      weapon = Weapon.create(reference: 'new_weapon', category: 'some_category', ranged: false)
      seed_files = Penman::RecordTag.generate_seed_for_model(Weapon)
      weapon.destroy

      run_seed(seed_files)

      weapon = Weapon.find_by(reference: 'new_weapon')
      expect(weapon).not_to be_nil
      expect(weapon.ranged).to be false
    end

    it 'should seed a simple model with associations' do
      item = Item.create(reference: 'new_item', asset: Asset.first)
      seed_files = Penman::RecordTag.generate_seed_for_model(Item)
      item.destroy

      run_seed(seed_files)

      item = Item.find_by(reference: 'new_item')
      expect(item).not_to be_nil
      expect(item.asset).to eq(Asset.first)
    end

    it 'should seed a simple model with the default candidate key' do
      item = Item.create(reference: 'new_item')

      seed_files = Penman::RecordTag.generate_seed_for_model(Item)
      item.destroy

      run_seed(seed_files)

      item = Item.find_by(reference: 'new_item')
      expect(item).not_to be_nil
    end

    it 'should seed a simple model with a non-default candidate key' do
      player = Player.create(name: 'new_player')
      seed_files = Penman::RecordTag.generate_seed_for_model(Player)
      player.destroy

      run_seed(seed_files)

      player = Player.find_by(name: 'new_player')
      expect(player).not_to be_nil
    end
  end

  # TODO: Create a number of chained relations like these:
  # describe '.seed_order' do
  #   let(:seed_order) { Penman::RecordTag.seed_order }

  #   it 'should order Collectible before CollectionMember' do
  #     expect(seed_order.find_index(Collectible)).to be < seed_order.find_index(CollectionMember)
  #   end

  #   it 'should order MultiSet before MultiSetMember' do
  #     expect(seed_order.find_index(MultiSet)).to be < seed_order.find_index(MultiSetMember)
  #   end

  #   it 'should properly order a chain of dependencies' do
  #     cm_index = seed_order.find_index(CollectionMember)
  #     expect(seed_order.find_index(Collectible)).to be < cm_index
  #     expect(cm_index).to be < seed_order.find_index(AbilitiesCollectionMember)
  #   end

  #   it 'should seed the proper order if multiple models are dependent on the same model' do
  #     cmc_index = seed_order.find_index(CollectionMembersCollection)
  #     expect(seed_order.find_index(CollectionMember)).to be < cmc_index
  #     expect(seed_order.find_index(Collection)).to be < cmc_index
  #   end
  # end

  describe '.create_custom' do
    it 'should create a custom tag using the provided values' do
      attributes = { record_type: 'Probably_a_yaml', tag: 'tag', candidate_key: 'candidate_key' }
      Penman::RecordTag.create_custom attributes
      expect(Penman::RecordTag.find_by(attributes)).not_to be_nil
    end

    it 'should fill in default values for those not provided' do
      Penman::RecordTag.create_custom(record_type: 'Probably_a_yaml')
      expect(Penman::RecordTag.find_by(record_type: 'Probably_a_yaml', tag: 'touched', candidate_key: 'n/a')).not_to be_nil
    end

    it 'should not create more than one tag if called multiple times with the same attributes' do
      Penman::RecordTag.create_custom(record_type: 'Probably_a_yaml')
      Penman::RecordTag.create_custom(record_type: 'Probably_a_yaml')
      Penman::RecordTag.create_custom(record_type: 'Probably_a_yaml')
      Penman::RecordTag.create_custom(record_type: 'Probably_a_yaml')
      expect(Penman::RecordTag.where(record_type: 'Probably_a_yaml').count).to eq(1)
    end
  end

  # TODO: Setup a model that is related on reference and setup this spec to work.
  #   This may require implementing an explicit method for defining dependancies.
  # describe 'Dungeon and Zone Seeds' do
  #   it 'should seed the correct zone into the dungeon table when the zone reference changes' do
  #     # The order of seeding is important here. We want to generate the zone seed first so that
  #     # it gets a lower timestamp, and is run first.
  #     # Otherwise we may be using find_by reference with a new zone reference that hasn't been seeded yet.
  #     dungeon = Dungeon.first
  #     zone = dungeon.zone
  #     dungeon_ref = dungeon.reference
  #     zone_name = zone.name
  #     dungeon.update!(reference: "#{dungeon.reference}_something_to_make_it_different")
  #     zone.update!(name: "#{zone_name}_something_to_make_it_different")

  #     seed_files = Penman::RecordTag.generate_seed_for_model(Zone)
  #     seed_files |= Penman::RecordTag.generate_seed_for_model(Dungeon)

  #     # set these back to what they were to simulate the state on the environment to be seeded
  #     dungeon.update!(reference: dungeon_ref)
  #     zone.update!(name: zone_name)

  #     run_seed(seed_files)

  #     expect(Dungeon.find_by(reference: dungeon_ref)).to be_nil
  #     expect(Zone.find_by(name: zone_name)).to be_nil

  #     dungeon = Dungeon.find_by(reference: "#{dungeon.reference}_something_to_make_it_different")
  #     zone = Zone.find_by(name: "#{zone_name}_something_to_make_it_different")
  #     expect(dungeon).not_to be_nil
  #     expect(zone).not_to be_nil
  #     expect(dungeon.zone).to eq(zone)
  #   end
  # end

  describe 'seeding phase for' do
    describe 'Item Seeds' do
      default_attributes = { reference: 'new_item_ref', asset_id: Asset.last.id }
      run_seed_spec_for_model(Item, default_attributes)
    end

    describe 'MultiSet Seeds' do
      default_attributes = { reference: 'some_great_new_multiset', weight: 1, quantity: 1 }
      run_seed_spec_for_model(MultiSet, default_attributes)
    end

    describe 'MultiSetMember Seeds' do
      default_attributes = {
        multi_set_id: MultiSet.last.id,
        setable_type: 'Item',
        setable_id: Item.last.id,
        weight: 1,
        quantity: 1,
      }
      run_seed_spec_for_model(MultiSetMember, default_attributes)
    end

    describe 'Player Seeds' do
      default_attributes = { name: 'some name' }
      run_seed_spec_for_model(Player, default_attributes)
    end

    describe 'Asset Seeds' do
      default_attributes = { reference: 'some reference' }
      run_seed_spec_for_model(Asset, default_attributes)
    end

    describe 'InventoryItem Seeds' do
      default_attributes = { player_id: Player.last.id, item_id: Item.last.id }
      run_seed_spec_for_model(InventoryItem, default_attributes)
    end
  end
end
