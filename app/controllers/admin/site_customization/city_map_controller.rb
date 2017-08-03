class Admin::SiteCustomization::CityMapController < Admin::SiteCustomization::BaseController
  authorize_resource :city_map, class: "SiteCustomization::CityMap"

  def edit
    @city_map = SiteCustomization::CityMap.find
  end

  def update
    @city_map = SiteCustomization::CityMap.new(city_map_params)
    if @city_map.save
      flash[:notice] = t("admin.site_customization.city_map.flash.update")
      redirect_to admin_site_customization_city_map_edit_path
    else
      flash.now[:alert] = t("admin.site_customization.city_map.flash.error_update")
      render :edit
    end
  end

  # TODO: Relocate method (Maybe this action should be better at new controller called "geocoder_controller" as "index" action)
  def geocode
    results = Geocoder.search(params[:term], { language: I18n.locale})
    render json: results
  end

  private

    def city_map_params
      params.require(:site_customization_city_map).permit(:address, :latitude, :longitude, :zoom)
    end

end
