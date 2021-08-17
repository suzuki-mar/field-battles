# frozen_string_literal: true

RSpec.describe ItemCalculator do
  describe 'execute' do
    before do
      Item.create_initial_items

      create_inventory_from_status_trait_and_item_params(
        :survivor, 
        [
          {name: Item::Name::FIJI_WATER, count: 2},
          {name: Item::Name::FIRST_AID_POUCH, count: 3}
        ]
      )

      create_inventory_from_status_trait_and_item_params(
        :survivor, 
        [
          {name: Item::Name::FIJI_WATER, count: 5},
          {name: Item::Name::CAMPBELL_SOUP, count: 6}
        ]
      )
      
    end
    
    subject do
      
      service = described_class.new
      filed = Filed.new
      filed.load_survivors

      service.execute(filed)
    end

    it 'アイテムごとの平均所持数を計算できること' do 
      expected = [
        {:name=>"Fiji Water", :count=>4},
        {:name=>"Campbell Soup", :count=>3},
        {:name=>"First Aid Pouch", :count=>2},
        {:name=>"AK47", :count=>0}
      ]
      
      expect(subject[:average_count_per_item]).to eq(expected)
    end

  end
  
  def create_inventory_from_status_trait_and_item_params(status_trait, item_params)
    player = create(:player, status_trait)    
    Inventory.create_for_newcomers(player.id, item_params)
  end

end
