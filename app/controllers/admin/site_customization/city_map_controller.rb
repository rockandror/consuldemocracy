class Admin::SiteCustomization::CityMapController < Admin::SiteCustomization::BaseController
  load_and_authorize_resource :image, class: "SiteCustomization::Image"

  def show
    @city_map = SiteCustomization::CityMap.find
  end

  def update
    @city_map = SiteCustomization::CityMap.new(city_map_params)
    if @city_map.save
      redirect_to admin_site_customization_city_map_path, notice: "Map updated"
    else
      flash.now[:alert] = "Error"
      render :show
    end
  end

  def geocode

  end

  private

    def city_map_params
      params.require(:site_customization_city_map).permit(:address, :latitude, :longitude, :zoom)
    end

end
