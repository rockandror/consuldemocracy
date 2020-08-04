require "application_responder"

class ApplicationController < ActionController::Base
  include HasFilters
  include HasOrders

  rescue_from StandardError, with: :audit_error
  after_action :audit

  before_action :authenticate_http_basic, if: :http_basic_auth_site?

  before_action :ensure_signup_complete
  before_action :set_locale
  before_action :track_email_campaign
  before_action :set_return_url

  check_authorization unless: :devise_controller?
  self.responder = ApplicationResponder

  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to main_app.root_url, alert: exception.message }
      format.json { render json: {error: exception.message}, status: :forbidden }
    end
  end

  layout :set_layout
  respond_to :html
  helper_method :current_budget

  def not_found
    raise StandardError.new "404"
  end

  private

  def set_audit_info
    unless @audit_info.nil?
      params[:audit_info] = @audit_info
    end
  end

  def audit_info(mensaje)
    logger.add(Logger::INFO, mensaje, "AUDIT")
  end

  def audit_error(exception)
    if Rails.env.production?
      if exception.to_s == "404"
        redirect_to "http://www.gobiernodecanarias.org/errors/errorctrl404.html"
      else
        redirect_to "http://www.gobiernodecanarias.org/errors/errorctrl500.html"
      end
      logger.add(Logger::ERROR, exception, "AUDIT")
      return
    end
    logger.add(Logger::ERROR, exception, "AUDIT")
    raise exception
  end

  def audit
    begin
      params[:ip] = request.remote_ip

      unless session.nil? || session.id.nil?
        params[:session_token] = session.id
      end

      params[:browser] = request.user_agent

      has_errors = response.body.include?('this-is-a-hidden-error-identifier-element') || response.body.include?('class="callout notice alert"')
      errors = nil

      if has_errors && response.body.include?('id="error_hashed_keys"')
        errors = response.body.match(/{+.(.)+.}>/).to_s.gsub('&gt;', '{').gsub('&quot;', "'")[0..-2]
      end


      message = EdoLogger.audit(current_user, params, has_errors, errors)

      logger.info("AUDIT") { message } unless message == {} || message.nil?
    rescue Exception => e
      logger.add(Logger::ERROR, e.message, "AUDIT_ERROR")
    end
  end

  def authenticate_http_basic
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.secrets.http_basic_username && password == Rails.application.secrets.http_basic_password
    end
  end

  def http_basic_auth_site?
    Rails.application.secrets.http_basic_auth
  end

  def verify_lock
    if current_user.locked?
      redirect_to account_path, alert: t('verification.alert.lock')
    end
  end

  def set_locale
    if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
      session[:locale] = params[:locale]
    end

    session[:locale] ||= I18n.default_locale

    locale = session[:locale]

    if current_user && current_user.locale != locale.to_s
      current_user.update(locale: locale)
    end

    I18n.locale = locale
    Globalize.locale = I18n.locale
  end

  def set_layout
    if devise_controller?
      "devise"
    else
      "application"
    end
  end

  def set_debate_votes(debates)
    @debate_votes = current_user ? current_user.debate_votes(debates) : {}
  end

  def set_proposal_votes(proposals)
    @proposal_votes = current_user ? current_user.proposal_votes(proposals) : {}
  end

  def set_spending_proposal_votes(spending_proposals)
    @spending_proposal_votes = current_user ? current_user.spending_proposal_votes(spending_proposals) : {}
  end

  def set_comment_flags(comments)
    @comment_flags = current_user ? current_user.comment_flags(comments) : {}
  end

  def ensure_signup_complete
    if user_signed_in? && !devise_controller? && current_user.registering_with_oauth
      redirect_to finish_signup_path
    end
  end

=begin
    def after_sign_in_path_for(user)
      user_url(user)
    end
    def after_sign_up_path_for(user)
      user_url(user)
    end
=end

  def verify_resident!
    unless current_user.residence_verified?
      redirect_to new_residence_path, alert: t('verification.residence.alert.unconfirmed_residency')
    end
  end

  def verify_verified!
    if current_user.level_three_verified?
      redirect_to(account_path, notice: t('verification.redirect_notices.already_verified'))
    end
  end

  def track_email_campaign
    if params[:track_id]
      campaign = Campaign.where(track_id: params[:track_id]).first
      ahoy.track campaign.name if campaign.present?
    end
  end

  def set_return_url
    if !devise_controller? && controller_name != 'welcome' && is_navigational_format?
      store_location_for(:user, request.path)
    end
  end

  def set_default_budget_filter
    if @budget.try(:balloting?) || @budget.try(:publishing_prices?)
      params[:filter] ||= "selected"
    end
  end

  def current_budget
    Budget.current
  end
end
