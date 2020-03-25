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
    current_date = Time.now
    if current_date.wday.to_i == 1
      @day = current_date.day
    else 
      diff = 7 - current_date.wday.to_i+1
      @day = (current_date +diff.days).day
    end
    Yt.configure do |config|
      Yt.configuration.api_key = 'AIzaSyAKYzMJUOq_sIhkg2JkCAfa2ckejHiy8rM'
      config.client_id = '674720534170-770sg35kq4qeqqr5n1vad2rg27fr12vo.apps.googleusercontent.com'
      config.client_secret = 'y8-zoS6zm22tDRUSz6516LAe' 
    end

    
    @channel = Yt::Channel.new id:  'UCFmaChI9quIY7lwHplnacfg'
    @video = Yt::Video.new id:  'KpgTWGu7ecI'

  end

  private

  def set_user_recommendations
    @recommended_debates = Debate.recommendations(current_user).sort_by_recommendations.limit(3)
    @recommended_proposals = Proposal.recommendations(current_user).sort_by_recommendations.limit(3)
  end

end
