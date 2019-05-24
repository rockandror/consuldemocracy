class Admin::Census::Locals::ImportationsController < Admin::Census::BaseController
  load_and_authorize_resource class: "Census::Local::Importation"

  def create
    @importation = Census::Local::Importation.new(importation_params)
    if @importation.save
      flash.now[:notice] = t("admin.census.locals.importations.create.notice")
      render :show
    else
      render :new
    end
  end

  private

    def importation_params
      return {} unless params[:census_local_importation].present?

      params.require(:census_local_importation).permit(:file)
    end
end
