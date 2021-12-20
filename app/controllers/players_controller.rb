# frozen_string_literal: true

class PlayersController < ApplicationController
  include RenderError

  def create
    @errors = []
    @player = Player.build_at_random_location(params)

    errors << Error.build_with_active_record(player) unless player.validate

    ActiveRecord::Base.transaction do
      register_for_newcomer!
    end

    if errors.present?
      render_error(errors)
      return
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

  attr_reader :player, :errors

  def register_for_newcomer!
    player.save

    inventory_errors = Inventory.validate_for_newcomer(player.id, params[:inventory])
    errors << Error.merge(inventory_errors) if inventory_errors.present?

    Inventory.register_for_newcomer!(player.id, params[:inventory])
    player.update!(status: Player.statuses[:survivor])

    raise ActiveRecord::Rollback if errors.present?
  end

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
