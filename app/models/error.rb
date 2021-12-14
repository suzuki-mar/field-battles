# frozen_string_literal: true

class Error
  attr_reader :messages

  def initialize(messages)
    @messages = messages
  end

  class << self 
    def build_with_message(message)
      new([message])
    end

    def build_with_active_record(record)
      new(record.errors.full_messages)
    end

    def merge(errors)
      messages = []
      errors.each do |error|
        messages.concat(error.messages) 
      end
      
      new(messages)
    end
  end


  module Key
    NOT_SAME_POINTS_TO_TRADE = 'NOT_SAME_POINTS_TO_TRADE'
    EXCHANGE_PARTNER_NOT_SURVIVOR = 'EXCHANGE_PARTNER_NOT_SURVIVOR'
  end

  attr_writer :messages  
  
end
