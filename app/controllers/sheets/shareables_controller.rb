class Sheets::ShareablesController < ApplicationController
  include SheetScoped

  def index
    @users = User.search_by_name(params[:name], Current.user.id) if params[:name].present?
  end
end
