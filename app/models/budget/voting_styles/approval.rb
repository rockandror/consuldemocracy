class Budget::VotingStyles::Approval < Budget::VotingStyles::Base
  def enough_resources?(investment)
    amount_available(investment.heading) > 0
  end

  def reason_for_not_being_ballotable(investment)
    :not_enough_available_votes unless enough_resources?(investment)
  end

  def not_enough_resources_error
    "insufficient votes"
  end

  def amount_available(heading)
    heading.max_votes - amount_spent(heading)
  end

  def amount_spent(heading)
    ballot.investments.by_heading(heading).count
  end

  def formatted_amount_available(heading)
    amount_available(heading)
  end

  def formatted_amount_spent(heading)
    amount_spent(heading)
  end
end
