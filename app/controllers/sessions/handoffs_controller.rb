# Opens in the Custom Tab: keeps the app's code for the callback, then starts the
# provider's flow, which OmniAuth only accepts as a POST from this page.
class Sessions::HandoffsController < ApplicationController
  skip_before_action :authenticate

  def show
    session[:session_handoff] = params.expect(:code)
    @provider = params[:provider]
  end

  # Asked by the app's page while it waits. Once the provider is done, the
  # before_action claiming the code redirects instead.
  def status
    head :no_content
  end
end
