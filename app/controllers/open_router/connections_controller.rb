class OpenRouter::ConnectionsController < ApplicationController
  before_action :set_pkce, :verify_state, only: :callback

  def create
    pkce = OpenRouter::Pkce.new
    session[:open_router_pkce] = { verifier: pkce.verifier, state: pkce.state }

    redirect_to pkce.authorize_url(callback_open_router_connection_url), allow_other_host: true
  end

  def callback
    Current.user.connect_open_router!(OpenRouter::Client.exchange_code(code: params[:code], verifier: @pkce.verifier))
    redirect_to new_recommendation_path, notice: I18n.t("notice.open_router.connect")
  end

  def destroy
    Current.user.disconnect_open_router!
    redirect_to new_recommendation_path, notice: I18n.t("notice.open_router.disconnect")
  end

  private

    def set_pkce
      @pkce = OpenRouter::Pkce.new(**session.delete(:open_router_pkce).to_h.symbolize_keys)
    end

    def verify_state
      redirect_to new_recommendation_path, notice: I18n.t("alert.open_router.connect") unless params[:state] == @pkce.state
    end
end
