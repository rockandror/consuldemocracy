class UsersController < ApplicationController
  has_filters %w{proposals debates budget_investments comments follows}, only: :show
  before_action :load_data, only: :edit
  load_and_authorize_resource
  helper_method :author?
  helper_method :current_user_is_author?
  helper_method :valid_interests_access?

  def show
    load_filtered_activity if valid_access?
  end

  def edit
    
  end

  def update    
    if !@user.profiles_id.blank?
      if @user.profiles_id.to_s != user_params[:profiles_id].to_s
        #remove_old_profile(@user)
        set_new_profile(@user, user_params[:profiles_id])
      end
    else
      set_new_profile(@user, user_params[:profiles_id]) 
    end
    @user.update_attributes(user_params)
    @user.geozone_id = user_params[:adress_attributes][:district]
    if @user.save
      redirect_to user_path(@user), notice: "Usuario actualizado." 
    else
      redirect_to user_path(@user), alert: @user.errors.full_messages
    end      
  rescue => e
    redirect_to user_path(@user), alert: e
  end

  def update_padron
    response = Padron.new.update_user(params[:user])
    if response == true
      redirect_to user_path(params[:user]), notice: "Dirección actualizada"
    else
      redirect_to user_path(params[:user]), alert: response
    end
  end

  private

    def user_params
      params.require(:user).permit(:id, :document_type, :document_number, :username, :email, :gender, :date_of_birth, :name, 
        :last_name, :last_name_alt, :phone_number, :profiles_id,
        adress_attributes: [:road_type, :road_name, :road_number, :floor, :gate, :door, :district, :borought, :postal_code, :id])
    end

    def set_activity_counts
      @activity_counts = ActiveSupport::HashWithIndifferentAccess.new(
                          proposals: Proposal.where(author_id: @user.id).count,
                          debates: (Setting["process.debates"] ? Debate.where(author_id: @user.id).count : 0),
                          budget_investments: (Setting["process.budgets"] ? Budget::Investment.where(author_id: @user.id).count : 0),
                          comments: only_active_commentables.count,
                          follows: @user.follows.map(&:followable).compact.count)
    end

    def load_filtered_activity
      set_activity_counts
      case params[:filter]
      when "proposals" then load_proposals
      when "debates" then load_debates
      when "budget_investments" then load_budget_investments
      when "ballot" then load_ballot
      when "comments" then load_comments
      when "follows" then load_follows
      else load_available_activity
      end
    end

    def load_available_activity
      if @activity_counts[:proposals] > 0
        load_proposals
        @current_filter = "proposals"
      elsif @activity_counts[:debates] > 0
        load_debates
        @current_filter = "debates"
      elsif @activity_counts[:budget_investments] > 0
        load_budget_investments
        @current_filter = "budget_investments"
      elsif  @activity_counts[:comments] > 0
        load_comments
        @current_filter = "comments"
      elsif  @activity_counts[:follows] > 0
        load_follows
        @current_filter = "follows"
      end
    end

    def load_proposals
      @proposals = Proposal.created_by(@user).order(created_at: :desc).page(params[:page])
      @p_hash = Hash.new
      count = 0
      @proposals.each do |p|
        @p_hash[count] = p.id
        count = count + 1
      end
    end

    def load_debates
      @debates = Debate.where(author_id: @user.id).order(created_at: :desc).page(params[:page])
    end

    def load_comments
      @comments = only_active_commentables
        .includes(:commentable, :moderated_contents)
        .order(created_at: :desc)
        .page(params[:page])
    end

    def load_budget_investments
      @budget_investments = Budget::Investment.where(author_id: @user.id).order(created_at: :desc).page(params[:page])
    end

    def load_follows
      @follows = @user.follows.group_by(&:followable_type)
    end

    def valid_access?
      @user.public_activity || authorized_current_user?
    end

    def valid_interests_access?
      @user.public_interests || authorized_current_user?
    end

    def load_ballot
      @ballot = Ballot.where(user: current_user).first_or_create if current_user_is_author?
    end

    def current_user_is_author?
      @current_user_is_author ||= current_user && current_user == @user
    end

    def author?(proposal)
      proposal.author_id == current_user.id if current_user
    end

    def authorized_current_user?
      @authorized_current_user ||= current_user && (current_user == @user || current_user.moderator? || current_user.administrator?)
    end

    def all_user_comments
      Comment.not_valuations.not_as_admin_or_moderator.where(user_id: @user.id)
    end

    def only_active_commentables
      disabled_commentables = []
      disabled_commentables << "Debate" unless Setting["process.debates"]
      disabled_commentables << "Budget::Investment" unless Setting["process.budgets"]
      if disabled_commentables.present?
        all_user_comments.where("commentable_type NOT IN (?)", disabled_commentables)
      else
        all_user_comments
      end
    end

    # def remove_old_profile(user)
    #   sql = "delete from "
    #   case user.profiles_id.to_s
    #     when "1" 
    #       sql = sql + "superadministrators"
    #       response = ActiveRecord::Base.connection.execute(sql + " where user_id = #{user.id}")
    #     when "2" 
    #       sql = sql + "administrators"
    #       response = ActiveRecord::Base.connection.execute(sql + " where user_id = #{user.id}")
    #     when "3" 
    #       sql = sql + "sures_administrators"
    #       response = ActiveRecord::Base.connection.execute(sql + " where user_id = #{user.id}")
    #     when "4" 
    #       sql = sql + "section_administrators"
    #       response = ActiveRecord::Base.connection.execute(sql + " where user_id = #{user.id}")
    #     when "5"
    #       sql = sql + "managers"
    #       response = ActiveRecord::Base.connection.execute(sql + " where user_id = #{user.id}")
    #     when "6"
    #       sql = sql + "moderators"
    #       response = ActiveRecord::Base.connection.execute(sql + " where user_id = #{user.id}")
    #     when "7"
    #       sql = sql + "valuators"
    #       response = ActiveRecord::Base.connection.execute(sql + " where user_id = #{user.id}")
    #     when "8"
    #       sql = sql + "consultants"
    #       response = ActiveRecord::Base.connection.execute(sql + " where user_id = #{user.id}")
    #     when "9"
    #       sql = sql + "editor"
    #       response = ActiveRecord::Base.connection.execute(sql + " where user_id = #{user.id}")
    #   end
    # end

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
      profile.user = user
      profile.save
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

    def superadmin
      !Superadministrator.find_by(user_id: current_user.id).blank?
    end

    def load_data
      @profiles={}
      Profile.all.each do |p|
        if !superadmin && p.code == "1"
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
