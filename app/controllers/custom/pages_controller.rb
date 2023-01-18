require_dependency Rails.root.join("app", "controllers", "pages_controller").to_s

class PagesController
  def show
    @custom_page = SiteCustomization::Page.published.find_by(slug: params[:id])
    string_array = params[:id].split('_')
    family = string_array[1]
    @related_pages = SiteCustomization::Page.published.where("slug LIKE :family", family: "\_#{family}\_%")
    @has_news = false
    if family == 'cabildo'
      @menu_title = 'Cabildo Abierto'
      @has_news = true
    elsif family == 'participacion'
      @menu_title = 'Participación y Colaboración Ciudadana'
    elsif family == 'etica'
      @menu_title = 'Ética Pública'
    else
      @menu_title = false
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
    @news = SiteCustomization::Page.where(is_news: true).order(news_date: :desc).page(params[:page]).per(5)
    @related_pages = SiteCustomization::Page.where("slug LIKE :family", family: "\_cabildo\_%")
    render action: :news
  end
end
