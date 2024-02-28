require_dependency Rails.root.join("app", "controllers", "admin", "site_customization",
                                   "pages_controller").to_s

class Admin::SiteCustomization::PagesController
  before_action :load_search, only: [:index, :search_pages]

  alias_method :consul_allowed_params, :allowed_params

  def search_pages
    @pages = ::SiteCustomization::Page.quick_search(@search)
    respond_to do |format|
      format.js
    end
  end

  private

    def allowed_params
      consul_allowed_params + [:is_news, :news_date, :updated_at]
    end

    def search_params
      params.permit(:text, :type, :start_date, :end_date)
    end

    def load_search
      @search = search_params
    end

    def resource_model
      SiteCustomization::Page
    end
end
