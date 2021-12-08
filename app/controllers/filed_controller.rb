# frozen_string_literal: true

class FiledController < ApplicationController
  before_action :set_field_in_which_loaded_survivor

  def index
    all_players = Player.all

    player_status_percentage = PlayerStatusPercentageCalculator.new.execute(all_players, filed)
    item_status = ItemCalculator.new.execute(filed)

    result = {
      infected_percentage: player_status_percentage[:infected_percentage],
      infected_percentage_including_zombies: player_status_percentage[:infected_percentage_including_zombies],
      noninfected_percentage: player_status_percentage[:noninfected_percentage],
      average_count_per_items: item_status[:average_count_per],
      wasted_item_points: item_status[:wasted_points]

    }

    render json: result
  end

  # TODO: Filed:locationのコントローラーを作成する
  def current_location
    ActiveRecord::Base.transaction do
      filed.move_the_survivors
      filed.attack_of_zombies
    end

    render json: { success: true }
  end

  # TODO: Filed:infectionのコントローラーを作成する
  def infection
    ActiveRecord::Base.transaction do
      filed.turning_into_infected
      filed.progress_of_infection
      filed.progress_of_zombification
    end

    render json: { success: true }
  end

  private

  attr_reader :filed

  def set_field_in_which_loaded_survivor
    @filed = Filed.new
    filed.load_survivors
    filed
  end
end
