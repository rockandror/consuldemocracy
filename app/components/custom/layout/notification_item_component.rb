require_dependency Rails.root.join("app", "components", "layout", "notification_item_component").to_s

class Layout::NotificationItemComponent < ApplicationComponent
  private

    def render?
      user && !user.guest?
    end
end
