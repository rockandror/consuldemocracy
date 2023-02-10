require_dependency Rails.root.join("app", "models", "widget", "card").to_s

class Widget::Card
  audited
end
