require_dependency Rails.root.join("app", "models", "proposal").to_s

class Proposal < ApplicationRecord
  translates :details, touch: true
  translates :request, touch: true

  globalize_accessors
end
