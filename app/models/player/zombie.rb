# frozen_string_literal: true

module Player
  class Zombie
    delegate :id, :current_location, :can_see?, to: :player

    def initialize(player)
      @player = player
    end

    def raid(target)
      return unless target.alive?
      return unless can_see?(target)

      player = Player.find(target.id)
      player.update_status!(:death)
    end

    private

    attr_reader :player
  end
end
