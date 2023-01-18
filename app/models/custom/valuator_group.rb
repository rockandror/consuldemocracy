require_dependency Rails.root.join("app", "models", "valuator_group").to_s

class ValuatorGroup
  audited on: [:create, :update, :destroy]
end
