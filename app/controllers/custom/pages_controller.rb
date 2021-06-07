class PagesController < ApplicationController
  include FeatureFlags
  skip_authorization_check

  feature_flag :help_page, if: lambda { params[:id] == "help/index" }

  def show
    puts params[:id]
    @custom_page = SiteCustomization::Page.published.find_by(slug: params[:id])
    string_array = params[:id].split('_')
    family = string_array[0]
    @related_pages = SiteCustomization::Page.where("slug LIKE :family", family: "#{family}%")
    if family == 'cabildo'
      @menu_title = 'Cabildo Abierto'
    elsif family == 'participacion'
      @menu_title = 'Participación y colaboración ciudadana'
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
end
