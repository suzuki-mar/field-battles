# frozen_string_literal: true

class Survivor
  delegate :id, :age, :counting_to_become_zombie, :save, to: :player

  def initialize(player)
    @player = player
    @turn_into_infected = false
  end

  def infected?
    player.status == Player.statuses[:infected]
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

  # 不必要にUPDATEのSQLが実行されないように、アップデートの実行は別のタイミングでおこなう
  def report_infected_players(targets)
    infecteds = targets.select(&:infected?)

    infecteds.each do |infected|
      next if infected.id == id

      infected.progress_of_zombie
    end
  end

  private

  attr_reader :player, :turn_into_infected
end
