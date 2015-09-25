class AddTestContent < ActiveRecord::Migration
  def change
    ActiveRecord::Base.transaction do
      ############# Assets #############
      assets = (1..5).map { |i| { reference: "asset_#{i}" } }
      assets = Asset.create!(assets)

      ############# Items #############
      items = (1..5).map { |i| { reference: "item_#{i}", asset: assets[i - 1] } }
      items = Item.create!(items)

      ############# Players #############
      players = (1..5).map { |i| { name: "player_#{i}" } }
      players = Player.create!(players)

      ############# InventoryItems #############
      inventory_items = (0...items.size).map do |i|
        { player: players[i], item: items[i] }
      end

      InventoryItem.create!(inventory_items)

      ############# MultiSets #############
      multi_sets = (1..5).map { |i| { reference: "multi_set_#{i}", weight: 1, quantity: 1 } }
      multi_sets = MultiSet.create!(multi_sets)

      ############# MultiSetMembers #############
      multi_set_members = (0...items.size).map do |i|
        { multi_set: multi_sets[i], setable: items[i] }
      end

      MultiSetMember.create!(multi_set_members)

      ############# Weapons #############
      weapons = (1..5).map { |i| { reference: "weapon_#{i}", damage_factor: 1, category: "type_#{i % 2}" } }
      Weapon.create!(weapons)
    end
  end
end
