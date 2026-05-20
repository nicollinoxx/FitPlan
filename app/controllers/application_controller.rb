class ApplicationController < ActionController::Base
  before_action :set_current_request_details
  before_action :authenticate, except: %i[ set_session_locale ]
  before_action :set_locale

  helper_method :current_user_avatar

  def set_session_locale
    session[:locale] = params[:locale] if has_locale_in_params?
    recede_or_redirect_to request.referer || root_path
  end

  private
    def authenticate
      if session_record = Session.find_by_id(cookies.signed[:session_token])
        Current.session = session_record
      else
        redirect_to welcome_path
      end
    end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end

    def current_user_avatar
      @current_user_avatar ||= Current.user&.avatar
    end

  protected

    def set_locale
      I18n.locale = session[:locale] || I18n.default_locale
    end

    def has_locale_in_params?
      params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)
    end
end
