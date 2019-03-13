class Migrations::SpendingProposal::DelegatedBallots
  attr_accessor :delegated_ballots

  def initialize
    @delegated_ballots = load_delegated_ballots
  end

  def migrate_all
    delegated_ballots.each do |ballot|
      migrate_delegated_ballot(ballot)
    end
  end

  private

    def load_delegated_ballots
      ::Ballot.where(user: User.forums)
    end


    def migrate_delegated_ballot(ballot)
      Migrations::SpendingProposal::DelegatedBallot.new(ballot).migrate_delegated_ballot
    end

end
