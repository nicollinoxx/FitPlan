class ApplicationController < ActionController::Base
  before_action :set_i18n_locale_from_params
  before_action :set_current_request_details
  before_action :authenticate

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
    def set_i18n_locale_from_params
      if params[:locale].present?
        if I18n.available_locales.map(&:to_s).include?(params[:locale])
          session[:locale] = params[:locale]
          I18n.locale = session[:locale]
        end
      else
        I18n.locale = session[:locale] || I18n.default_locale
      end
    end
end
