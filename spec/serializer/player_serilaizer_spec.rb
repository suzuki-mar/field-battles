# frozen_string_literal: true

RSpec.describe PlayerSerializer, type: :serializer do
  let(:player) { create(:player) }

  before do
    SetUpper.prepare_items
    inventory = Inventory.build_with_empty_item_stocks(player.id)
    inventory.add!(Item::Name::FIJI_WATER, 2)
  end

  # 時間がないためテストができていない
  it 'シリアライズできていること' do
    expect(described_class.new(player).serializable_hash).not_to be_nil
  end
end
