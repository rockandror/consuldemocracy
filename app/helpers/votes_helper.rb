module VotesHelper

  def debate_percentage_of_likes(debate)
    debate.likes.percent_of(debate.total_votes)
  end

  def votes_percentage(vote, debate)
    return "0%" if debate.total_votes == 0
    if vote == "likes"
      debate_percentage_of_likes(debate).to_s + "%"
    elsif vote == "dislikes"
      (100 - debate_percentage_of_likes(debate)).to_s + "%"
    end
  end

  def topic_percentage_of_likes(topic)
    topic.likes.percent_of(topic.total_votes)
  end

  def topic_votes_percentage(vote, topic)
    return "0%" if topic.total_votes == 0
    if vote == "likes"
      topic_percentage_of_likes(topic).to_s + "%"
    elsif vote == "dislikes"
      (100 - topic_percentage_of_likes(topic)).to_s + "%"
    end
  end

  def css_classes_for_vote(votes, votable)
    case votes[votable.id]
    when true
      {in_favor: "voted", against: "no-voted"}
    when false
      {in_favor: "no-voted", against: "voted"}
    else
      {in_favor: "", against: ""}
    end
  end

  def voted_for?(votes, votable)
    votes[votable.id]
  end

end
