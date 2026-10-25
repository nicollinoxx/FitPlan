class OpenRouter::UsagesController < ApplicationController
  def show
    @free_requests = Current.user.open_router_free_requests
  end
end
