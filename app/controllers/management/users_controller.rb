class Management::UsersController < Management::BaseController
  before_action :load_data
  def new    
    @user = User.new()
  end

  def create
    verify_address = false
    user_params[:adress_attributes].each do |k,v|
      verify_address = true if !v.blank?
    end

    @user = User.new(user_params)
    @user.terms_of_service = "1"

    if verify_address == true
      @user.residence_verified_at = Time.current
    end
    @user.geozone_id = @user.adress.district
    @user.verified_at = Time.current
    pass = Digest::SHA1.hexdigest("#{@user.created_at.to_s}--#{@user.username}")[0,8].upcase
    @user.password = pass
    @user.password_confirmation = pass
    @user.geozone_id = user_params[:adress_attributes][:district]

    if @user.save
      set_new_profile(@user, user_params[:profiles_id]) if !user_params[:profiles_id].blank?
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
        if p.code == "1" && !superadmin
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

    def set_new_profile(user, id)
      case id
        when "1" then true if set_superadmin(user)
        when "2" then true if set_admin(user)
        when "3" then true if set_sures_admin(user)
        when "4" then true if set_section_admin(user)
        when "5" then true if set_manager(user)
        when "6" then true if set_moderator(user)
        when "7" then true if set_evaluator(user)
        when "8" then true if set_consultant(user)
        when "9" then true if set_editor(user)
      end
    end

    def set_superadmin(user)
      profile = Superadministrator.new
      profile.user_id = user.id
      profile.save!
    end

    def set_admin(user)
      profile = Administrator.new
      profile.user = user
      profile.save
    end

    def set_sures_admin(user)
      profile = SuresAdministrator.new
      profile.user = user
      profile.save
    end

    def set_section_admin(user)
      profile = SectionAdministrator.new
      profile.user = user
      profile.save
    end

    def set_manager(user)
      profile = Manager.new
      profile.user = user
      profile.save
    end

    def set_moderator(user)
      profile = Moderator.new
      profile.user = user
      profile.save
    end

    def set_evaluator(user)
      profile = Valuator.new
      profile.user = user
      profile.save
    end

    def set_consultant(user)
      profile = Consultant.new
      profile.user = user
      profile.save
    end

    def set_editor(user)
      profile = Editor.new
      profile.user = user
      profile.save
    end

end
