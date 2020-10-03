class Budgets::SupportsInfoComponent < ApplicationComponent
  delegate :current_user, to: :helpers
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  def total_supports
    Vote.where(votable: budget.investments, voter: current_user, vote_flag: true).count
  end
end
