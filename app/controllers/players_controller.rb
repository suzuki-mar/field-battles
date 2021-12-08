# frozen_string_literal: true

class PlayersController < ApplicationController
  def create
    player = Player.build_at_random_location(params)

    ActiveRecord::Base.transaction do
      player.save!
      Inventory.create_for_newcomers(player.id, params[:inventory])
      player.update!(status: Player.statuses[:survivor])
    end

    render json: { success: true, player: player.serializable_hash }
  end

  def update_inventory
    player = Player.find(params[:id])

    usecase = PlayerContexts::ExchangeItems.new
    result = usecase.execute(player, build_params_of_update_inventory)

    return render json: { error_keys: result[:error_keys] }, status: :bad_request unless result[:sucess]

    render json: { success: true }, status: :ok
  end

  private

  def build_params_of_update_inventory
    usecase_params = {}

    usecase_params[:requeser_items] = build_item_params(params.required(:requeser_items))
    usecase_params[:partner_items] =  build_item_params(params.required(:partner_items))
    usecase_params[:partner_player_id] = params.required(:partner_player_id)
    usecase_params
  end

  def build_item_params(params)
    params.map do |param|
      { name: param[:name], count: param[:count].to_i }
    end
  end
end
