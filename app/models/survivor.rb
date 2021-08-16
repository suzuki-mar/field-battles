# frozen_string_literal: true

class Survivor
  delegate :id, :age, :counting_to_become_zombie, :can_see?, :save, to: :player

  def initialize(player)
    @player = player
  end

  def infected?
    player.status == Player.statuses[:infected]
  end

  def non_infected?
    player.status == Player.statuses[:survivor]
  end

  def alive?
    non_infected? || infected?
  end

  def turn_into_infected?
    rand(2).zero?
  end

  def become_infected
    player.update!(status: Player.statuses[:infected])
  end

  def become_zombie
    return false unless fully_infected?

    player.update!(status: Player.statuses[:zombie])
  end

  def progress_of_zombie
    return if fully_infected?

    player.counting_to_become_zombie = player.counting_to_become_zombie - 1
  end

  def fully_infected?
    player.counting_to_become_zombie.zero?
  end

  def assign_next_locations
    location = Location.build_distance_to_travel
    player.assign_attributes(
      current_lat: player.current_lat + location.lat,
      current_lon: player.current_lon + location.lon
    )
  end

  def current_location
    Location.build_current_location(player)
  end

  # 不必要にUPDATEのSQLが実行されないように、アップデートの実行は別のタイミングでおこなう
  def report_infected_players(targets)
    infecteds = targets.select(&:infected?)

    infecteds.each do |infected|
      next if infected.id == id
      next unless can_see?(infected)

      infected.progress_of_zombie
    end
  end

  private

  attr_reader :player
end
