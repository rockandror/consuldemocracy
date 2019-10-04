class Admin::Wizards::Verification::FieldsController < Admin::Verification::BaseController
  layout "wizard"
  include Translatable

  before_action :set_field, only: [:edit, :update, :destroy]

  def index
    @fields = ::Verification::Field.all.order(:position)
  end

  def new
    @field = ::Verification::Field.new
  end

  def create
    @field = ::Verification::Field.new(verification_field_params)
    if @field.save
      notice = t("admin.wizards.verification.fields.create.notice")
      redirect_to admin_wizards_verification_fields_path, notice: notice
    else
      flash.now[:error] = t("admin.wizards.verification.fields.create.error")
      render :new
    end
  end

  def edit
  end

  def update
    if @field.update(verification_field_params)
      notice = t("admin.wizards.verification.fields.update.notice")
      redirect_to admin_wizards_verification_fields_path, notice: notice
    else
      flash.now[:error] = t("admin.wizards.verification.fields.update.error")
      render :edit
    end
  end

  def destroy
    @field.destroy
    notice = t("admin.wizards.verification.fields.destroy.notice")
    redirect_to admin_wizards_verification_fields_path, notice: notice
  end

  private

    def verification_field_params
      attributes = [:name, :position, :required, :request_path, :response_path, :confirmation_validation, :format]
      translations_attributes = translation_params(::Verification::Field)

      params.require(:verification_field).permit(*attributes, translations_attributes)
    end

    def set_field
      @field = ::Verification::Field.find(params[:id])
    end
end
