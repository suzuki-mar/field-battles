# frozen_string_literal: true

module PlayerContexts
  class RegisterNewSurvivor
    def execute(params)
      initial_location = Location.build_distance_to_travel
      player = Player.new(
        name: params[:name], age: params[:age], current_lat: initial_location.lat, current_lon: initial_location.lon
      )

      ActiveRecord::Base.transaction do
        player.save
        Inventory.create_for_newcomers(player.id, params[:inventory])
        player.update(status: Player.statuses[:survivor])
      end

      { sucess: true, player: player }
    end

    private

    attr_reader :params, :player
  end
end
