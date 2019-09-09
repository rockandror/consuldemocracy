class Admin::Verification::ResidentsController < Admin::Verification::BaseController
  authorize_resource class: "Verification::Resident"
  before_action :set_resident, only: [:edit, :update, :destroy]

  def index
    @residents = Verification::Resident.all
    @residents = @residents.page(params[:page])
  end

  def new
    @resident = Verification::Resident.new
  end

  def create
    @resident = Verification::Resident.new(verification_resident_params)
    if @resident.save
      redirect_to admin_verification_residents_path,
        notice: t("admin.verification.residents.create.notice")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @resident.update(verification_resident_params)
      redirect_to admin_verification_residents_path,
        notice: t("admin.verification.residents.update.notice")
    else
      render :edit
    end
  end

  def destroy
    @resident.destroy
    redirect_to admin_verification_residents_path,
      notice: t("admin.verification.residents.destroy.notice")
  end

  private

    def verification_resident_params
      params.require(:verification_resident).permit(:data)
    end

    def set_resident
      @resident = Verification::Resident.find(params[:id])
    end
end
