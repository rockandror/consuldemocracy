require_dependency Rails.root.join("app", "models", "budget", "content_block").to_s

class Budget
  class ContentBlock
    audited
  end
end
