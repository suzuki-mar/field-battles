# frozen_string_literal: true

class Player::Zombie
  delegate :id, :current_location, :can_see?, to: :player

  def initialize(player)
    @player = player
  end

  def raid(target)
    return unless target.alive?
    return unless can_see?(target)

    player = Player.find(target.id)
    player.update(status: Player.statuses[:death])
  end

  private

  attr_reader :player
end
