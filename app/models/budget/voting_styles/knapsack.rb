class Budget::VotingStyles::Knapsack < Budget::VotingStyles::Base
  def enough_resources?(investment)
    investment.price.to_i <= amount_available(investment.heading)
  end

  def reason_for_not_being_ballotable(investment)
    :not_enough_money unless enough_resources?(investment)
  end

  def not_enough_resources_error
    "insufficient funds"
  end

  def amount_available(heading)
    ballot.budget.heading_price(heading) - amount_spent(heading)
  end

  def amount_spent(heading)
    ballot.investments.by_heading(heading.id).sum(:price).to_i
  end

  def formatted_amount_available(heading)
    ballot.budget.formatted_amount(amount_available(heading))
  end

  def formatted_amount_spent(heading)
    ballot.budget.formatted_amount(amount_spent(heading))
  end
end
