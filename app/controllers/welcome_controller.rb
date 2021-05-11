class WelcomeController < ApplicationController
  skip_authorization_check
  before_action :set_user_recommendations, only: :index, if: :current_user
  before_action :authenticate_user!, only: :welcome
  before_action :get_key_youtube, only: [:encuentrosconexpertos, :eventos, :agend_admin]

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
    begin
      @videoId = Setting.find_by(key: "youtube_connect").value
    rescue
      @videoId = ""
    end
    begin
      @playlistId = Setting.find_by(key: "youtube_playlist_connect").value
    rescue
      @playlistId = ""
    end
  end

  def eventos
    begin
      @videoId = Setting.find_by(key: "eventos_youtube_connect").value
    rescue
      @videoId = ""
    end
    begin
      @playlistId = Setting.find_by(key: "eventos_youtube_playlist_connect").value
    rescue
      @playlistId = ""
    end
  end

  def agend_admin
    begin
      @videoId =  Setting.find_by(key: "agend_youtube_connect").value
    rescue
      @videoId = ""
    end
    begin 
      @playlistId = Setting.find_by(key: "agend_youtube_playlist_connect").value
    rescue
      @playlistId = ""
    end
    @event_agends = EventAgend.all.order(date_at: :asc).group_by(&:date_at)
  rescue
    @videoId = ""
    @playlistId = ""
    @event_agends = nil
  end

  private

  def get_key_youtube
    @key = Rails.application.secrets.yt_api_key
    @key_x = Rails.application.secrets.yt_api_key_x
    @embed_domain = Rails.application.secrets.embed_domain
  rescue
    @key= ""
    @key_x=""
    @embed_domain = ""
  end

  def set_user_recommendations
    @recommended_debates = Debate.recommendations(current_user).sort_by_recommendations.limit(3)
    @recommended_proposals = Proposal.recommendations(current_user).sort_by_recommendations.limit(3)
  end

end
