require_dependency Rails.root.join("app", "controllers", "admin", "site_customization", "pages_controller").to_s

class Admin::SiteCustomization::PagesController
  before_action :load_search, only: [:index]

  def search_pages
    load_search
    @pages = ::SiteCustomization::Page.quick_search(@search)
    respond_to do |format|
      format.js
    end
  end

  private

    def page_params #ToDo
      attributes = [:slug, :more_info_flag, :print_content_flag, :is_news, :news_date, :updated_at, :status]

      params.require(:site_customization_page).permit(*attributes,
        translation_params(SiteCustomization::Page)
      )
    end

    def search_params
      params.permit(:text, :type, :start_date, :end_date)
    end

    def load_search
      @search = search_params
      @search
    end

    def resource_model
      SiteCustomization::Page
    end
end
