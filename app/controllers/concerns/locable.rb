module Locable
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
    after_action :publish_locale
  end

  def change_locale
    remember_locale if has_locale_in_params?
    redirect_to request.referer || root_path
  end

  private

    def set_locale
      I18n.locale = current_locale
    end

    def current_locale
      Current.user&.locale || stored_locale || device_locale || I18n.default_locale
    end

    def stored_locale
      cookies[:locale].presence_in(I18n.available_locales.map(&:to_s))
    end

    def device_locale
      request.headers["Accept-Language"].to_s[/\A[a-z]{2}/].presence_in(I18n.available_locales.map(&:to_s))
    end

    def has_locale_in_params?
      params[:locale].present? && I18n.available_locales.include?(params[:locale].to_sym)
    end

    def publish_locale
      chosen = Current.user&.locale or return
      cookies.permanent[:locale] = chosen unless cookies[:locale] == chosen
    end

    def remember_locale
      if Current.user
        Current.user.update!(locale: params[:locale])
      else
        cookies.permanent[:locale] = params[:locale]
      end
    end
end
