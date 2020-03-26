class WelcomeController < ApplicationController
  skip_authorization_check
  before_action :set_user_recommendations, only: :index, if: :current_user
  before_action :authenticate_user!, only: :welcome

  layout "devise", only: [:welcome, :verification]

  def index
    @header = Widget::Card.header.first
    @feeds = Widget::Feed.active
    @cards = Widget::Card.body
    @banners = Banner.in_section("homepage").with_active
  end

  def welcome
    if current_user.level_three_verified?
      redirect_to page_path("welcome_level_three_verified")
    elsif current_user.level_two_or_three_verified?
      redirect_to page_path("welcome_level_two_verified")
    else
      redirect_to page_path("welcome_not_verified")
    end
  end

  def verification
    redirect_to verification_path if signed_in?
  end

  def encuentrosconexpertos
    @i ||= 0
    if !params[:aumento].blank?
      @i = @i + 1 
    elsif !params[:decremento].blank?
      @i = @i == 0 ? 0 : @i - 1 
    end
   
    Yt.configure do |config|
      config.api_key = Rails.application.secrets.yt_api_key
      config.client_id = Rails.application.secrets.yt_client_id
      config.client_secret = Rails.application.secrets.yt_client_secret
    end

    
    # @playlist = Yt::Playlist.new id:  'PLhnvwI6F9eqXTZQc1yUGl4GX9s96u1AmK'
    # @video = Yt::Video.new id:  'KpgTWGu7ecI'
  end

  private

  def set_user_recommendations
    @recommended_debates = Debate.recommendations(current_user).sort_by_recommendations.limit(3)
    @recommended_proposals = Proposal.recommendations(current_user).sort_by_recommendations.limit(3)
  end

end
