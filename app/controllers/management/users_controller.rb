class Management::UsersController < Management::BaseController
  before_action :load_data
  def new    
    @user = User.new()
  end

  def create
    @user = User.new(user_params)

    @user.terms_of_service = "1"
    @user.residence_verified_at = Time.current
    @user.verified_at = Time.current
    pass = Digest::SHA1.hexdigest("#{@user.created_at.to_s}--#{@user.username}")[0,8].upcase
    @user.password = pass
    @user.password_confirmation = pass
    
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

    def superadmin
      user_id = session[:manager]["login"].split("_")
      !Superadministrator.find_by(user_id: User.find(user_id[2].to_i)).blank?
    end

    def load_data
      @profiles={}
      Profile.all.each do |p|
        if p.id == 1 && !superadmin
          nil
        else
          @profiles.merge!({p.name => p.code })
        end
      end

      @districts ={}
      Geozone.all.each do |g|
        @districts.merge!({g.name => g.id })
      end

      @boroughts = {}
      Proposal.all.where(comunity_hide: :true).each do |borought|
        @boroughts.merge!({borought.title => borought.id })
      end

      @document_types = {
        "NIF" => "1",
        "Pasaporte" => "2",
        "Tarjeta de residencia" => "3"
      }

      @gender = {
        "Masculino" => "Male",
        "Femenino" => "Female"
      }
    end

end
