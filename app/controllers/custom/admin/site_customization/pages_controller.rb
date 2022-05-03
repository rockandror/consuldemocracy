class Admin::SiteCustomization::PagesController < Admin::SiteCustomization::BaseController
  include Translatable

  before_action :load_search, only: [:index]
  load_and_authorize_resource :page, class: "SiteCustomization::Page"

  def index
    @pages = SiteCustomization::Page.order("slug").page(params[:page])
  end

  def search_pages
    load_search
    @pages = ::SiteCustomization::Page.quick_search(@search)
    respond_to do |format|
      format.js
    end
  end

  def create
    if @page.save
      notice = t("admin.site_customization.pages.create.notice")
      redirect_to admin_site_customization_pages_path, notice: notice
    else
      flash.now[:error] = t("admin.site_customization.pages.create.error")
      render :new
    end
  end

  def update
    if @page.update(page_params)
      notice = t("admin.site_customization.pages.update.notice")
      redirect_to admin_site_customization_pages_path, notice: notice
    else
      flash.now[:error] = t("admin.site_customization.pages.update.error")
      render :edit
    end
  end

  def destroy
    @page.destroy!
    notice = t("admin.site_customization.pages.destroy.notice")
    redirect_to admin_site_customization_pages_path, notice: notice
  end

  private

    def page_params
      attributes = [:slug, :more_info_flag, :print_content_flag, :is_news, :news_date, :updated_at, :status]

      params.require(:site_customization_page).permit(*attributes,
        translation_params(SiteCustomization::Page)
      )
    end

    def search_params
      params.permit(:slug, :search)
    end

    def load_search
      @search = search_params[:search]
    end

    def resource
      SiteCustomization::Page.find(params[:id])
    end

    def resource_model
      SiteCustomization::Page
    end
end
