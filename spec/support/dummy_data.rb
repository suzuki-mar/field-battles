# frozen_string_literal: true

class DummyData
  class << self
    def age
      Faker::Number.between(from: 18, to: 65)
    end

    def lat
      Faker::Address.latitude.round(6)
    end

    def lon
      Faker::Address.longitude.round(6)
    end

    def item_name
      'Fiji Water'
    end
  end
end
