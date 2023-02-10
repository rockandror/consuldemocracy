require_dependency Rails.root.join("app", "models", "widget", "feed").to_s

class Widget::Feed
  audited
end
