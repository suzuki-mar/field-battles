# frozen_string_literal: true

class Filed
  attr_reader :survivors, :infected_survivors

  LON_RANGE = (-100.0..100.0)
  LAT_RANGE = (-100.0..100.0)

  def initialize
    @infected_survivors = []
  end

  def load_survivors
    players = Player.where(status: [Player.statuses[:survivor], Player.statuses[:infected]])
    @survivors = players.map { |p| Survivor.new(p) }
  end

  def turning_into_infected
    survivors.each do |survivor|
      survivor.become_infected if !survivor.infected? && survivor.turn_into_infected?
    end
  end

  def progress_of_infection
    survivors.each { |s| s.report_infected_players(survivors) }
    select_infected_survivors.each(&:save)
  end

  def select_infected_survivors
    survivors.select { |s| s.infected? || s.fully_infected? }
  end

  def progress_of_zombification
    select_infected_survivors.each do |s|
      next unless s.fully_infected?

      s.become_zombie
    end
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
    zombies = zombie_players.map { |p| Zombie.new(p) }
    zombies.each do |zombie|
      survivors.each { |s| zombie.raid(s) }
    end
  end

  def can_move?(survivor)
    LON_RANGE.cover?(survivor.current_location.lon) && LAT_RANGE.cover?(survivor.current_location.lat)
  end
end
