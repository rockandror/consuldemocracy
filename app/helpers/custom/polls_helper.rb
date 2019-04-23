require_dependency "#{Rails.root}/app/helpers/polls_helper"

module Custom::PollsHelper
  def show_link_to_first_voting?(poll)
    poll.starts_at == Time.parse("13-02-2017") && poll.ends_at == Time.parse("19-02-2017")
  end
end

module PollsHelper
  alias_method :consul_link_to_poll, :link_to_poll

  def link_to_poll(text, poll)
    if show_link_to_first_voting?(poll)
      link_to text, first_voting_path
    else
      consul_link_to_poll text, poll
    end
  end
end
