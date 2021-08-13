class ReportsController < ApplicationController
  def index
    render json: { message: "OK" }    
  end  
end
