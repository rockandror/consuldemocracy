class Management::UsersController < Management::BaseController

  def new
    @profiles={}
    Profile.all.name.each do |p|
      @profiles.merge!({p.name => p.id })
    end
    @user = User.new()
  end

  def create
    @user = User.new(user_params)

    # if @user.email.blank?
    #   user_without_email
    # else
    #   user_with_email
    # end

    @user.terms_of_service = "1"
    @user.residence_verified_at = Time.current
    @user.verified_at = Time.current
    @user.password = "Admin12345678"
    @user.password_confirmation = "Admin12345678"
    
    if @user.save
      render :show
    else
      render :new
    end
  end

  def erase
    managed_user.erase(t("management.users.erased_by_manager", manager: current_manager["login"])) if current_manager.present?
    destroy_session
    redirect_to management_document_verifications_path, notice: t("management.users.erased_notice")
  end

  def logout
    destroy_session
    redirect_to management_root_url, notice: t("management.sessions.signed_out_managed_user")
  end

  private

    def user_params
      params.require(:user).permit(:document_type, :document_number, :username, :email, :gender, :date_of_birth, :name, 
        :last_name, :last_name_alt, :phone_number, :profiles_id,
        adress_attributes: [:road_type, :road_name, :road_number, :floor, :gate, :door, :district, :borought, :postal_code])
    end

    def destroy_session
      session[:document_type] = nil
      session[:document_number] = nil
      clear_password
    end

    def user_without_email
      new_password = "aAbcdeEfghiJkmnpqrstuUvwxyz23456789$!".split("").sample(10).join("")
      @user.password = new_password
      @user.password_confirmation = new_password

      @user.email = nil
      @user.confirmed_at = Time.current

      @user.newsletter = false
      @user.email_on_proposal_notification = false
      @user.email_digest = false
      @user.email_on_direct_message = false
      @user.email_on_comment = false
      @user.email_on_comment_reply = false
    end

    def user_with_email
      @user.skip_password_validation = true
    end

end
