# frozen_string_literal: true

class Filed
  attr_reader :survivors, :zombies

  LON_RANGE = (-100.0..100.0)
  LAT_RANGE = (-100.0..100.0)

  def load_survivors
    players = Player.only_survivor
    @survivors = players.map { |p| Player::Survivor.new(p) }
  end

  def load_zombies
    players = Player.where(status: Player.statuses[:zombie])
    @zombies = players.map { |p| Player::Zombie.new(p) }
  end

  def infection_progresses!
    survivors.each do |s|
      s.become_infected! if !s.infected? && s.turn_into_infected?
    end

    report_of_infection_by_survivors!

    zombification_of_fully_infected!
  end

  def move_the_survivors
    survivors.each do |s|
      s.assign_next_locations

      loop do
        break if can_move?(s)

        s.assign_next_locations
      end

      s.save
    end
  end

  def attack_of_zombies
    zombie_players = Player.where(status: Player.statuses[:zombie])
    zombies = zombie_players.map { |p| Player::Zombie.new(p) }
    zombies.each do |zombie|
      survivors.each { |s| zombie.raid(s) }
    end
  end

  def can_move?(survivor)
    LON_RANGE.cover?(survivor.current_location.lon) && LAT_RANGE.cover?(survivor.current_location.lat)
  end

  private

  def zombification_of_fully_infected!
    fully_infected_survivors = survivors.select(&:fully_infected?)
    fully_infected_survivors.each do |s|
      next unless s.fully_infected?

      s.become_zombie!
    end
  end

  def report_of_infection_by_survivors!
    survivors.each do |s|
      another_survivors = survivors - [s]
      s.report_infected_players!(another_survivors)
    end
  end
end
