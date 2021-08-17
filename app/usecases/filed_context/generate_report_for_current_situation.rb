# frozen_string_literal: true

module FiledContext
  class GenerateReportForCurrentSituation
    def execute
      filed = Filed.new
      all_players = Player.all
      filed.load_survivors
      player_status_percentage = PlayerStatusPercentageCalculator.new.execute(all_players, filed)
      item_status = ItemCalculator.new.execute(filed)

      {
        infected_percentage: player_status_percentage[:infected_percentage],
        infected_percentage_including_zombies: player_status_percentage[:infected_percentage_including_zombies],
        noninfected_percentage: player_status_percentage[:noninfected_percentage],
        average_count_per_items: item_status[:average_count_per],
        wasted_item_points: item_status[:wasted_points]

      }
    end
  end
end
