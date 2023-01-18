require_dependency Rails.root.join("app", "models", "valuator").to_s

class Valuator
  audited on: [:create, :update, :destroy]
end
