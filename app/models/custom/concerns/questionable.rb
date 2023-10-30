require_dependency Rails.root.join("app", "models", "concerns", "questionable").to_s

module Questionable
  alias_method :consul_find_by_attributes, :find_by_attributes

  private

    def find_by_attributes(user, title)
      if vote_type == "open"
        { author: user }
      else
        consul_find_by_attributes(user, title)
      end
    end
end
