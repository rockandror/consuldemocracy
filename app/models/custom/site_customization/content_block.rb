require_dependency Rails.root.join("app", "models", "site_customization", "content_block").to_s

class SiteCustomization::ContentBlock
  audited
end
