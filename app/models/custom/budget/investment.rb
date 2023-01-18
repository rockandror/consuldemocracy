require_dependency Rails.root.join("app", "models", "budget", "investment").to_s

class Budget
  class Investment
    audited_options[:on] << :create
    after_create :audit_create
  end
end
