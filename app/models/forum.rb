class Forum < ActiveRecord::Base
  belongs_to :user

  def votes_for(geozone_scope)
    user.votes.for_spending_proposals(SpendingProposal.send("#{geozone_scope}_wide"))
  end
end
