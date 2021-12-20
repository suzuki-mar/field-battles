# frozen_string_literal: true

class Survivor
  attr_reader :errors

  delegate :id, :age, :counting_to_become_zombie, :can_see?, :save, to: :player

  def initialize(player)
    @player = player
    @errors = []
  end

  delegate :infected?, to: :player

  def non_infected?
    player.survivor?
  end

  def alive?
    non_infected? || infected?
  end

  def turn_into_infected?
    infection_will_progress = random.zero?

    return false unless infection_will_progress

    inventory = fetch_inventory
    if inventory.has_item?(Item::Name::FIRST_AID_POUCH)
      inventory.use!(Item::Name::FIRST_AID_POUCH)
      return false
    end

    true
  end

  def become_infected
    player.update!(status: Player.statuses[:infected])
  end

  def become_zombie
    return false unless fully_infected?

    player.update!(status: Player.statuses[:zombie])
  end

  def progress_of_zombie!
    if non_infected?
      errors << Error.build_with_message(I18n.t('error_message.survivor.turn_into_zombie_when_not_infected'))

      raise ActiveRecord::Rollback
    end

    return if fully_infected?

    player.update!(counting_to_become_zombie: player.counting_to_become_zombie - 1)
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
  def report_infected_players!(targets)
    infecteds = targets.select(&:infected?)

    infecteds.each do |infected|
      next if infected.id == id
      next unless can_see?(infected)

      infected.progress_of_zombie!
    end
  end

  private

  attr_reader :player, :inventory

  def fetch_inventory
    return inventory if inventory.present?

    @inventory = Inventory.fetch_by_player_id(id)
    inventory
  end

  # テスト時に値を挿入できるようにするためにメソッドを作成している
  def random
    rand(2)
  end
end
