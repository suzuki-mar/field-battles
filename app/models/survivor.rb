class Survivor
  delegate :id, :age, to: :player

  def initialize(player)
    @player = player
  end

  private 
  attr_reader :player

end