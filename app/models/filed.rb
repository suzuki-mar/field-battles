# frozen_string_literal: true

class Filed
  attr_reader :survivors, :infected_survivors

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
    # binding.pry

    select_infected_survivors.each do |s|
      next unless s.fully_infected?

      s.become_zombie
    end
  end
end
