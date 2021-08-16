# frozen_string_literal: true

module FiledContext
  class MoveWhereabouts
    def execute
      filed = Filed.new
      filed.load_survivors

      ActiveRecord::Base.transaction do
        filed.move_the_survivors
        filed.attack_of_zombies
      end

      true
    end
  end
end
