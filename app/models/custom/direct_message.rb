require_dependency Rails.root.join("app", "models", "direct_message").to_s

class DirectMessage
  audited
end
