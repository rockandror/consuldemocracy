class Budget
  class InvestmentInterest < ActiveRecord::Base
    belongs_to :user
    belongs_to :budget_investment
  end
end
