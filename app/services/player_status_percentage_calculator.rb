# frozen_string_literal: true

class PlayerStatusPercentageCalculator
  def execute(all_players, filed)
    @all_players = all_players
    @filed = filed

    count_grouping_survivors = count_grouping_survivors_by_infection_status
    count_infected_including_zombie = filed.load_zombies.count + count_grouping_survivors[:infected]

    {
      infected_percentage: calc_percentage_of_target_of_all_players(count_grouping_survivors[:infected]),
      infected_percentage_including_zombies: calc_percentage_of_target_of_all_players(count_infected_including_zombie),
      noninfected_percentage: calc_percentage_of_target_of_all_players(count_grouping_survivors[:noninfected])
    }
  end

  private

  attr_reader :all_players, :filed

  def count_grouping_survivors_by_infection_status
    count_group = { infected: 0, noninfected: 0 }

    filed.survivors.each do |s|
      if s.infected?
        count_group[:infected] = count_group[:infected] + 1
        next
      end

      if s.noninfected?
        count_group[:noninfected] = count_group[:noninfected] + 1
        next
      end
    end

    count_group
  end

  def calc_percentage_of_target_of_all_players(target)
    (target.to_f / all_players.count).round(3)
  end
end
