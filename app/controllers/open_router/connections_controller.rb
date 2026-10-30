class OpenRouter::ConnectionsController < ApplicationController
  skip_before_action :authenticate, only: :callback
  before_action :resume_session, :set_connecting_user, only: :callback

  # Lands in the browser that started the flow, or in a Custom Tab from the
  # native apps, where nobody is signed in and the page just says to go back.
  def callback
    @user.connect_open_router!(OpenRouter::Client.exchange_code(code: params[:code], verifier: OpenRouter::Pkce.new(params[:state]).verifier))
    redirect_to new_recommendation_path, notice: I18n.t("notice.open_router.connect") if Current.user
  end

  def destroy
    Current.user.disconnect_open_router!
    redirect_to new_recommendation_path, notice: I18n.t("notice.open_router.disconnect")
  end

  private

    def set_connecting_user
      @user = User.find_signed(params[:state].to_s, purpose: :open_router_connection)
      redirect_to new_recommendation_path, notice: I18n.t("alert.open_router.connect") unless @user
    end
end
