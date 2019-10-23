class Admin::Verification::Residents::ImportsController < Admin::Verification::Residents::BaseController
  load_and_authorize_resource class: "Verification::Residents::Import"

  def create
    @import = Verification::Residents::Import.new(verification_residents_import_params)
    if @import.save
      flash.now[:notice] = t("admin.verification.residents.imports.create.notice")
      render :show
    else
      render :new
    end
  end

  private

    def verification_residents_import_params
      return {} unless params[:verification_residents_import].present?

      params.require(:verification_residents_import).permit(:file)
    end
end
