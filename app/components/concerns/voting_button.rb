module VotingButton
  extend ActiveSupport::Concern

  def is_pressed?(resource, user, value)
    case user&.voted_as_when_voted_for(resource)
    when true
      value == "yes"
    when false
      value == "no"
    else
      false
    end
  end

  def button_method(resource, value)
    user_already_voted_with(resource, value) ? "delete" : "post"
  end

  def user_already_voted_with(resource, value)
    current_user&.voted_as_when_voted_for(resource) == parse_vote(value)
  end

  def parse_vote(value)
    value == "yes"
  end
end
