class Admin::SiteCustomization::CityMapController < Admin::SiteCustomization::BaseController
  authorize_resource :city_map, class: "SiteCustomization::CityMap"

  def show
    @city_map = SiteCustomization::CityMap.find
  end

  def update
    @city_map = SiteCustomization::CityMap.new(city_map_params)
    if @city_map.save
      redirect_to admin_site_customization_city_map_path, notice: t("admin.site_customization.city_map.success")
    else
      flash.now[:alert] = t("admin.site_customization.city_map.error")
      render :show
    end
  end

  def geocode
    results = Geocoder.search(params[:term], { language: I18n.locale})
    render json: results
  end

  private

    def city_map_params
      params.require(:site_customization_city_map).permit(:address, :latitude, :longitude, :zoom)
    end

end
