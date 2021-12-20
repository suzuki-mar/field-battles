# frozen_string_literal: true

module RenderError
  extend ActiveSupport::Concern

  def render_error(errors)
    messages = []
    errors.each do |error|
      messages.concat(error.messages)
    end

    response = { messages: messages }
    render json: { success: false, errors: response }, status: :bad_request
  end
end
