class Admin::Wizards::Verification::FieldsController < Admin::Wizards::BaseController
  include Translatable

  before_action :set_field, only: [:edit, :update, :destroy]

  def index
    @fields = ::Verification::Field.all.order(:position)
  end

  def new
    @field = ::Verification::Field.new
  end

  def create
    @field = ::Verification::Field.new(field_params)
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
    if @field.update(field_params)
      notice = t("admin.wizards.verification.fields.update.notice")
      redirect_to admin_wizards_verification_fields_path, notice: notice
    else
      flash.now[:error] = t("admin.wizards.verification.fields.update.error")
      render :edit
    end
  end

  def destroy
    @field.destroy!
    notice = t("admin.wizards.verification.fields.destroy.notice")
    redirect_to admin_wizards_verification_fields_path, notice: notice
  end

  private

    def field_params
      params.require(:verification_field).permit(field_attributes)
    end

    def field_attributes
      [:name, :position, :required, :confirmation_validation, :format,
       :checkbox_link, :kind, :represent_min_age_to_participate,
       :represent_geozone, :visible, translation_params(::Verification::Field),
       options_attributes: options_attributes]
    end

    def options_attributes
      [:value, :id, :destroy, translation_params(::Verification::Field::Option)]
    end

    def set_field
      @field = ::Verification::Field.find(params[:id])
    end
end
