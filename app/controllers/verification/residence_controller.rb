class Verification::ResidenceController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_verified!
  before_action :verify_lock, only: [:new, :create]
  skip_authorization_check

  include VerificationHelper
  include ActiveModel::Dates

  def new
    @residence = Verification::Residence.new
  end

  def create
    # Platino
    params=residence_params
    date_of_birth = parse_date('date_of_birth', params)
    @residence = Verification::Residence.new(params.merge(user: current_user))

    begin
      unless SaraNet.new.verify_residence("request_id", document_typesById[params[:document_type].to_s], params[:document_number], params[:genero][0].upcase, date_of_birth, params[:postal_code])
        @residence.errors.add(:residence_in_madrid, true)
        return render :new
      end
    rescue
      @residence.errors.add(:platino, true)
      return render :new
    end

    if @residence.save
      redirect_to verified_user_path, notice: t('verification.residence.create.flash.success')
    else
      render :new
    end
  end

  private

  def residence_params
    params.require(:residence).permit(:document_number, :document_type, :date_of_birth, :postal_code, :genero, :terms_of_service)
  end
end
