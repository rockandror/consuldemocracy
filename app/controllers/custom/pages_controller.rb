class PagesController < ApplicationController
  include FeatureFlags
  skip_authorization_check

  feature_flag :help_page, if: lambda { params[:id] == "help/index" }

  def show
    puts params[:id]
    @custom_page = SiteCustomization::Page.published.find_by(slug: params[:id])
    string_array = params[:id].split('_')
    family = string_array[1]
    @related_pages = SiteCustomization::Page.where("slug LIKE :family", family: "\_#{family}\_%")
    if family == 'cabildo'
      @menu_title = 'Cabildo Abierto'
      @has_news = true
    elsif family == 'participacion'
      @menu_title = 'Participación y colaboración ciudadana'
      @has_news = false
    else
      @menu_title = false
      @has_news = false
    end

    if @custom_page.present?
      @cards = @custom_page.cards
      render action: :custom_page
    else
      render action: params[:id]
    end
  rescue ActionView::MissingTemplate
    head 404, content_type: "text/html"
  end

  def news
    @menu_title = 'Cabildo Abierto'
    @news = SiteCustomization::Page.where(is_news: true)
    @related_pages = SiteCustomization::Page.where("slug LIKE :family", family: "\_cabildo\_%")
    render action: :news
  end
end
