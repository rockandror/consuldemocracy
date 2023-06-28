class Shared::InFavorAgainstComponent < ApplicationComponent
  include VotingButton
  attr_reader :votable
  delegate :current_user, :votes_percentage, to: :helpers

  def initialize(votable)
    @votable = votable
  end

  private

    def agree_aria_label
      t("votes.agree_label", title: votable.title)
    end

    def disagree_aria_label
      t("votes.disagree_label", title: votable.title)
    end

    def vote_in_favor_against_path(value)
      if user_already_voted_with(votable, value)
        remove_vote_path(value)
      else
        if votable.class.name == "Debate"
          debate_votes_path(votable, value: value)
        else
          legislation_process_proposal_votes_path(votable.process, votable, value: value)
        end
      end
    end

    def remove_vote_path(value)
      vote = votable.votes_for.find_by!(voter: current_user)
      if votable.class.name == "Debate"
        debate_vote_path(votable, vote, value: value)
      else
        legislation_process_proposal_vote_path(votable.process, votable, vote, value: value)
      end
    end
end
