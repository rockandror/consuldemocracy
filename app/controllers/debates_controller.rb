class DebatesController < ApplicationController
  include FeatureFlags
  include CommentableActions
  include FlagActions

  before_action :parse_tag_filter, only: :index
  before_action :authenticate_user!, except: [:index, :show, :map, :borought, :new_borought]
  before_action :load_geozones, only: [:index, :map, :borought, :new_borought]
  before_action :set_view, only: :index
  before_action :debates_recommendations, only: :index, if: :current_user

  feature_flag :debates

  invisible_captcha only: [:create, :update], honeypot: :subtitle

  has_orders ->(c) { Debate.debates_orders(c.current_user) }, only: :index
  has_orders %w{newest most_voted oldest}, only: :show

  load_and_authorize_resource
  helper_method :resource_model, :resource_name
  respond_to :html, :js
  def index
    super
    if !current_user.blank? && current_user.section_administrator? && !current_user.geozone_id.blank?
      @debates = Debate.where(geozone_id: current_user.geozone_id)
    end
    @debates = @debates.page(params[:page]).per(3)
  end
  def index_customization
    @featured_debates = @debates.featured
    discard_probe_debates
    
    @geozones_coords = district_geozone
    @key = Rails.application.secrets.yt_api_key
    @key_x = Rails.application.secrets.yt_api_key_x
    @embed_domain = Rails.application.secrets.embed_domain
    @videoId = Setting.find_by(key: "youtube_connect").value
    @playlistId = Setting.find_by(key: "youtube_playlist_connect").value
  end

  def show
    super
    @related_contents = Kaminari.paginate_array(@debate.relationed_contents).page(params[:page]).per(5)
    redirect_to debate_path(@debate), status: :moved_permanently if request.path != debate_path(@debate)
  end

  def vote
    @debate.register_vote(current_user, params[:value])
    set_debate_votes(@debate)
    log_event("debate", "vote", I18n.t("tracking.events.name.#{params[:value]}"))
  end

  def unmark_featured
    @debate.update_attribute(:featured_at, nil)
    redirect_to debates_path
  end

  def mark_featured
    @debate.update_attribute(:featured_at, Time.current)
    redirect_to debates_path
  end

  def discard_probe_debates
    @resources = @resources.not_probe
  end

  def disable_recommendations
    if current_user.update(recommended_debates: false)
      redirect_to debates_path, notice: t("debates.index.recommendations.actions.success")
    else
      redirect_to debates_path, error: t("debates.index.recommendations.actions.error")
    end
  end

  def borought
    @district = Geozone.find(params[:geozone])
    @proposals = Proposal.where(geozone_id: params[:geozone],comunity_hide: true).order(title: :asc)
  end

  def district_geozone
    cords = {
    "Moncloa-Aravaca" => "43,189,39,201,82,222,96,252,94,289,154,267,152,238,158,234,160,225,165,217,157,207,133,201,77,201", 
    "Tetuán" => "162,208,185,206,181,238,162,233",
    "Chamartín" => "180,249,190,195,215,195,209,243,193,251",  
    "Hortaleza" => "221,161,203,192,224,239,264,238,243,217,272,183,261,166",  
    "Barajas" => "270,176,281,177,302,168,316,169,342,221,335,249,264,240,246,219,272,189", 
    "Latina" => "38,288,56,329,95,336,112,317,111,312,121,308,147,283,152,270,97,288,86,296",  
    "Chamberí" => "151,240,164,236,180,238,182,256,179,263,165,259,154,258",  
    "Ciudad Lineal" => "214,216,212,245,209,272,246,281,238,247",  
    "San Blas-Canillejas" => "235,239,334,248,313,254,284,277,273,293,247,281",   
    "Salamanca" => "182,251,174,271,209,274,210,248,209,243",   
    "Centro" => "155,257,154,283,165,287,176,284,175,277,177,269,177,262,168,258", 
    "Retiro" => "178,271,176,285,193,303,209,275",   
    "Moratalaz" => "204,286,219,302,237,311,245,282,219,281,213,276,210,275",   
    "Vicálvaro" => "247,283,237,309,263,321,259,334,304,356,319,314,335,317,343,304,340,288,328,279,316,290,301,286,288,287,285,280,273,297",  
    "Arganzuela"  => "145,283,147,290,163,300,177,316,195,304,178,286,166,285,155,281",  
    "Carabanchel"  => "147,336,114,343,95,338,142,286,162,298,146,314",   
    "Usera"  => "163,299,147,314,145,333,159,338,182,340,181,333,175,326,175,314",   
    "Puente de Vallecas"  => "183,342,184,331,178,327,178,315,195,306,205,288,221,302,239,312,220,330,203,339",  
    "Villaverde"  => "144,337,135,369,148,385,189,386,199,380,188,353,183,342",
    "Villa de Vallecas"  => "241,309,216,335,196,342,181,341,202,380,213,377,232,398,240,399,248,406,274,406,268,399,304,357,261,337,261,322",  
    "Fuencarral-El Pardo"  => "164,210,128,200,115,199,79,201,43,187,46,156,30,149,33,137,16,89,2,70,21,46,31,56,83,45,77,32,84,31,90,37,90,46,112,45,150,65,183,70,196,44,219,30,225,5,235,5,239,6,252,12,257,36,265,39,264,54,279,63,278,72,258,85,242,85,231,81,222,65,186,76,197,95,208,132,202,141,208,143,220,161,213,176,204,192,192,194,188,204"  
    }
  end

  def new_borought
    if user_signed_in?
      if !params[:debate][:borought_id].blank?
      community = Community.find(Proposal.find(params[:debate][:borought_id]).community_id)
      redirect_to new_community_topic_path(community)
      else
        redirect_to debates_path, alert: t("debates.index.recommendations.actions.blank")
      end
    else
      redirect_to new_user_session_path, alert: t("devise.failure.unauthenticated")
    end
  end

  private

    def debate_params
      params.require(:debate).permit(:title, :description, :tag_list, :comment_kind, :terms_of_service)
    end

    def resource_model
      Debate
    end

    def set_view
      @view = (params[:view] == "minimal") ? "minimal" : "default"
    end

    def debates_recommendations
      if Setting["feature.user.recommendations_on_debates"] && current_user.recommended_debates
        @recommended_debates = Debate.recommendations(current_user).sort_by_random.limit(3)
      end
    end

end
