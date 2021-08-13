# frozen_string_literal: true

class ReportsController < ApplicationController
  def index
    render json: { message: 'OK' }
  end
end
