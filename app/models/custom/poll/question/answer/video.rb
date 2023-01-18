require_dependency Rails.root.join("app", "models", "poll", "question", "answer", "video").to_s

class Poll::Question::Answer::Video
  audited on: [:create, :update, :destroy]
end
