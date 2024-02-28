require_dependency Rails.root.join("app", "controllers", "pages_controller").to_s

class PagesController
  alias_method :consul_show, :show

  def show
    string_array = params[:id].split("_")
    family = string_array[1]
    @related_pages = SiteCustomization::Page.published.where("slug LIKE :family", family: "_#{family}_%")
    @has_news = false
    if family == "cabildo"
      @menu_title = "Cabildo Abierto"
      @has_news = true
    elsif family == "participacion"
      @menu_title = "Participación y Colaboración Ciudadana"
    elsif family == "etica"
      @menu_title = "Ética Pública"
    else
      @menu_title = false
    end

    consul_show
  end

  def news
    @menu_title = "Cabildo Abierto"
    @news = SiteCustomization::Page.where(is_news: true).order(news_date: :desc).page(params[:page]).per(5)
    @related_pages = SiteCustomization::Page.where("slug LIKE :family", family: "_cabildo_%")
    render action: :news
  end
end
