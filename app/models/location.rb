# frozen_string_literal: true

class Location
  attr_reader :lon, :lat

  DISTANCE_TO_SEEABLE = 15

  def initialize(lon, lat)
    @lon = lon
    @lat = lat
  end

  def self.build_distance_to_travel
    lon = rand(0.0...10.0).round(6)
    lat = rand(0.0...10.0).round(6)

    new(lon, lat)
  end

  def can_sight?(compare)
    lon_range = (-DISTANCE_TO_SEEABLE + lon..DISTANCE_TO_SEEABLE + lon)
    lat_range = (-DISTANCE_TO_SEEABLE + lat..DISTANCE_TO_SEEABLE + lat)
    lon_range.cover?(compare.lon) && lat_range.cover?(compare.lat)
  end

  def self.build_current_location(player)
    new(player.current_lon, player.current_lat)
  end

  def equal(compare)
    lon == compare.lon && lat == compare.lat
  end
end
