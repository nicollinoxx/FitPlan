class ApplicationController < ActionController::Base
  before_action :set_current_request_details
  before_action :authenticate, except: %i[ set_session_locale ]
  before_action :set_locale

  def set_session_locale
    session[:locale] = params[:locale] if I18n.available_locales.include?(params[:locale].to_sym)

    recede_or_redirect_to root_path
  end

  private
    def authenticate
      if session_record = Session.find_by_id(cookies.signed[:session_token])
        Current.session = session_record
      else
        redirect_to sign_in_path
      end
    end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end

  protected

    def set_locale
      I18n.locale = session[:locale] || I18n.default_locale
    end
end
