class Admin::SiteCustomization::Pages::IndexComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "admin", "site_customization", "pages",
                                   "index_component").to_s

class Admin::SiteCustomization::Pages::IndexComponent
  attr_reader :search
  alias_method :consul_initialize, :initialize

  def initialize(pages, search: {})
    consul_initialize(pages)
    @search = search
  end
end
