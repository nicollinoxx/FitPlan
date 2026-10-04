class ApplicationController < ActionController::Base
  before_action :set_current_request_details
  before_action :authenticate, except: %i[ change_locale ]
  before_action :resume_session, only: %i[ change_locale ]
  before_action :set_locale
  after_action :publish_locale

  helper_method :current_user_avatar

  def change_locale
    remember_locale if has_locale_in_params?
    recede_or_redirect_to request.referer || root_path
  end

  private
    def authenticate
      redirect_to welcome_path unless resume_session
    end

    def resume_session
      Current.session = Session.find_by_id(cookies.signed[:session_token])
    end

    # Signed in, the language belongs to the account and follows the person to
    # their next browser. Signed out, the cookie is all there is to hold it.
    def remember_locale
      if Current.user
        Current.user.update!(locale: params[:locale])
      else
        cookies.permanent[:locale] = params[:locale]
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
      I18n.locale = current_locale
    end

    # An account's language is mirrored into the cookie, which is what the
    # native apps watch. Only a language someone asked for is written: were the
    # one merely inferred from the device published, it would freeze there and
    # the browser would stop following its own setting.
    #
    # It runs after the action because the action is where the language
    # changes, and a cookie written before it would report the previous one.
    def publish_locale
      chosen = Current.user&.locale or return
      cookies.permanent[:locale] = chosen unless cookies[:locale] == chosen
    end

    def current_locale
      Current.user&.locale || stored_locale || device_locale || I18n.default_locale
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
