# frozen_string_literal: true

module PlayerContexts
  class WorseningOfInfection
    def execute
      filed = Filed.new
      filed.load_survivors

      ActiveRecord::Base.transaction do
        filed.turning_into_infected
        filed.progress_of_infection
        filed.progress_of_zombification
      end

      true
    end
  end
end
