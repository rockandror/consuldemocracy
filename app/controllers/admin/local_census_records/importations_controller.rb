class Admin::LocalCensusRecords::ImportationsController < Admin::LocalCensusRecords::BaseController
  load_and_authorize_resource class: "LocalCensusRecords::Importation"

  def create
    @importation = LocalCensusRecords::Importation.new(local_census_records_importation_params)
    if @importation.save
      flash.now[:notice] =  t("admin.local_census_records.importations.create.notice")
      render :show
    else
      render :new
    end
  end

  private

    def local_census_records_importation_params
      return {} unless params[:local_census_records_importation].present?

      params.require(:local_census_records_importation).permit(:file)
    end
end
