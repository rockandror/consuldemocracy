class Budget::VotingStyles::Base
  attr_reader :ballot

  def initialize(ballot)
    @ballot = ballot
  end

  def name
    self.class.name.split("::").last.underscore
  end

  def change_vote_info(link:)
    I18n.t("budgets.investments.index.sidebar.change_vote_info.#{name}", link: link)
  end

  def amount_available_info(heading)
    I18n.t("budgets.ballots.show.remaining.#{name}",
           amount: formatted_amount_available(heading))
  end

  def amount_spent_info(heading)
    I18n.t("budgets.ballots.show.amount_spent.#{name}",
           amount: formatted_amount_spent(heading))
  end
end
