require_dependency Rails.root.join("app", "models", "site_customization", "image").to_s

class SiteCustomization::Image
  audited on: [:create, :update, :destroy]
end
