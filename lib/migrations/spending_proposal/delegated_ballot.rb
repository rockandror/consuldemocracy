class Migrations::SpendingProposal::DelegatedBallot
  attr_accessor :delegated_ballot

  def initialize(delegated_ballot)
    @delegated_ballot = delegated_ballot
  end

  def migrate_delegated_ballot
    represented_users.each do |represented_user|
      migrate_ballot(represented_user)
    end
  end

  private

    def represented_users
      forum.represented_users
    end

    def forum
      delegated_ballot.user.forum
    end

    def migrate_ballot(represented_user)
      Migrations::SpendingProposal::Ballot.new(delegated_ballot, represented_user).migrate_ballot
    end

end
