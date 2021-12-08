# frozen_string_literal: true

module Usecase
  class ExchangeItemsValidator
    attr_reader :error_keys

    def valid?(params)
      @params = params
      @item_name_and_points = Item.fetch_all_name_and_point
      @error_keys = []

      unless calc_items_point(params[:requeser_items]) == calc_items_point(params[:partner_items])
        error_keys.push(Error::Key::NOT_SAME_POINTS_TO_TRADE)
      end

      error_keys.push(Error::Key::EXCHANGE_PARTNER_NOT_SURVIVOR) unless Player.survivor?(params[:partner_player_id])

      error_keys.blank?
    end

    private

    attr_reader :params, :item_name_and_points

    def calc_items_point(items)
      point = 0

      items.each do |item|
        name_and_point = item_name_and_points.find do |np|
          item[:name] == np[:name]
        end

        point += (name_and_point[:point] * item[:count])
      end

      point
    end
  end
end
