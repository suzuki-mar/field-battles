class ReportOnBeingZombie
  def execute 
    self.fields = Filed.new
    active_players = fields.fetch_active_players
    infected_survivors = check_survivors_turning_into_infected(active_players)
    update_infection_status(active_players)
    
    active_players = filter_active_players(active_players)    
    turn_confirmed_infected_players_into_zombie(active_players)

    return true
  end

  private 
  attr_reader :fields

  def check_survivors_turning_into_infected(active_players)
    infected_survivors = []
    survivors.each{|survivor|
      if !survivor.infected? && survivor.turn_into_infected? 
        survivor.become_infected
        
        if survivor.infected? 
          infected_survivors << survivor
        end
        
      end      
    }

    infected_survivors
  end

  def filter_active_players(survivors)
    active_players = []

    survivors.find do |s|
      s.can_active?
    end
  end

  def update_infection_status(active_players)
    active_players.each do |ap|
      ap.report_infected_players_if_close_proximity(infected_survivors)
    end
    this.fields.update_infected_players(infected_survivors)
  end

  def turn_confirmed_infected_players_into_zombie(active_players)
    newly_turned_zombies = active_players.select do |player| 
      return player.fully_infected?
    end

    self.field.turn_into_zombies(newly_turned_zombies)

  end
  
end

# テストケース
# 生存者が存在している場合
# エラーケース
# 生存者が存在していない場合