# frozen_string_literal: true

class FiledController < ApplicationController
  def index
    render json: FiledContext::GenerateReportForCurrentSituation.new.execute
  end

  # TODO Filed:locationのコントローラーを作成する
  def current_location
    filed = Filed.new
    filed.load_survivors

    ActiveRecord::Base.transaction do
      filed.move_the_survivors
      filed.attack_of_zombies
    end
    
    render json: { success: true }
  end

  # TODO Filed:infectionのコントローラーを作成する
  def infection
    filed = Filed.new
    filed.load_survivors

    ActiveRecord::Base.transaction do
      filed.turning_into_infected
      filed.progress_of_infection
      filed.progress_of_zombification
    end
        
    render json: { success: true }
  end
end
