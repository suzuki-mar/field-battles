# frozen_string_literal: true

class FiledController < ApplicationController
  def index
    render json: FiledContext::GenerateReportForCurrentSituation.new.execute
  end

  def current_location
    usecase = FiledContext::MoveWhereabouts.new
    usecase.execute
    render json: { success: true }
  end

  def infection
    usecase = FiledContext::WorseningOfInfection.new
    usecase.execute
    render json: { success: true }
  end
end