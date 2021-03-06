# frozen_string_literal: true

RSpec.describe ItemCalculator do
  describe 'execute' do
    subject do
      service = described_class.new
      filed = Filed.new
      filed.load_survivors
      service.execute(filed)
    end

    before do
      Item.create_initial_items

      create_inventory_from_status_trait_and_item_params(
        :noninfected,
        [
          { name: Item::Name::FIJI_WATER, count: 2 },
          { name: Item::Name::FIRST_AID_POUCH, count: 3 }
        ]
      )

      create_inventory_from_status_trait_and_item_params(
        :noninfected,
        [
          { name: Item::Name::FIJI_WATER, count: 5 },
          { name: Item::Name::CAMPBELL_SOUP, count: 6 }
        ]
      )

      create_inventory_from_status_trait_and_item_params(
        :zombie,
        [
          { name: Item::Name::FIJI_WATER, count: 1 },
          { name: Item::Name::CAMPBELL_SOUP, count: 1 }
        ]
      )

      create_inventory_from_status_trait_and_item_params(
        :death,
        [
          { name: Item::Name::FIJI_WATER, count: 1 },
          { name: Item::Name::CAMPBELL_SOUP, count: 1 }
        ]
      )
    end

    it 'アイテムごとの平均所持数を計算できること' do
      expected = [
        { name: 'Fiji Water', count: 4 },
        { name: 'Campbell Soup', count: 3 },
        { name: 'First Aid Pouch', count: 2 },
        { name: 'AK47', count: 0 }
      ]

      expect(subject[:average_count_per]).to match_array(expected)
    end

    it '非生存者担ってしまったプレイヤーの総ポイント数' do
      expect(subject[:wasted_points]).to eq(52)
    end
  end

  def create_inventory_from_status_trait_and_item_params(status, item_params)
    player = create(:player, :newcomer)
    Inventory.register_for_newcomer!(player.id, item_params)

    player.update(status: Player.statuses[status])
  end
end
