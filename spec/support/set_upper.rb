# frozen_string_literal: true

class SetUpper
  class << self
    def prepare_items
      Item.create_initial_items
    end

    def prepare_filed
      prepare_items
    end
  end
end
