class ApplicationController < ActionController::Base
  before_action :set_current_request_details
  before_action :authenticate, except: %i[ change_locale ]
  before_action :set_locale

  helper_method :current_user_avatar

  def change_locale
    cookies.permanent[:locale] = params[:locale] if has_locale_in_params?
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
      I18n.locale = stored_locale || device_locale || I18n.default_locale
    end

    # The language used to live in the session, which the native apps cannot
    # read. They keep one web view per tab, so a tab that was off screen when
    # the language changed went on showing the old one until it was pulled
    # down by hand. A cookie they can read is what ends that.
    #
    # Anyone can write it, so it is read as a suggestion.
    def stored_locale
      cookies[:locale].presence_in(I18n.available_locales.map(&:to_s))
    end

    def device_locale
      request.headers["Accept-Language"].to_s[/\A[a-z]{2}/].presence_in(I18n.available_locales.map(&:to_s))
    end

    def has_locale_in_params?
      params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)
    end
end
