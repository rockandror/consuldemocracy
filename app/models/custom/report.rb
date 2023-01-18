require_dependency Rails.root.join("app", "models", "report").to_s

class Report
  audited on: [:create, :update, :destroy]
end
