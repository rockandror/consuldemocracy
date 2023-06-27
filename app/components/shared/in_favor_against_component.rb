class Shared::InFavorAgainstComponent < ApplicationComponent
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

    def pressed?(value)
      case current_user&.voted_as_when_voted_for(votable)
      when true
        value == "yes"
      when false
        value == "no"
      else
        false
      end
    end

    def vote_in_favor_against_path(value)
      if user_already_voted_with(value)
        remove_vote_path(value)
      else
        #WIP: polymorphic_path(votable, action: :vote, value: "yes")
        if votable.class.name == "Debate"
          debate_votes_path(votable, value: value)
        else
          legislation_process_proposal_votes_path(votable.process, votable, value: value)
        end
      end
    end

    def user_already_voted_with(value)
      current_user&.voted_as_when_voted_for(votable) == parse_vote(value)
    end

    def remove_vote_path(value)
      vote = votable.votes_for.find_by!(voter: current_user)
      #WIP: polymorphic_path(votable, action: :vote, value: "yes")
      if votable.class.name == "Debate"
        debate_vote_path(votable, vote, value: value)
      else
        legislation_process_proposal_vote_path(votable.process, votable, vote, value: value)
      end
    end

    def parse_vote(value)
      value == "yes" ? true : false
    end
end
